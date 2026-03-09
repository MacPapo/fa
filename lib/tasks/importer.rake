require "csv"

namespace :db do
  desc "Importazione totale, ottimizzata e sequenziale del database legacy"
  task import_all: :environment do
    puts "🚀 Inizio Super Importazione Legacy...\n\n"

    # Spegniamo il logging di AR per massimizzare le performance
    ActiveRecord::Base.logger = nil

    import_locations
    import_contacts
    import_jobs_and_itineraries
    import_participations

    puts "\n🎉 IMPORTAZIONE COMPLETATA CON SUCCESSO! IL DATABASE È PRONTO."
  end

  # --- METODI PRIVATI DEL TASK ---

  def reset_sqlite_sequence(table)
    ActiveRecord::Base.connection.execute(
      "UPDATE sqlite_sequence SET seq = (SELECT MAX(id) FROM #{table}) WHERE name = '#{table}'"
    )
  rescue StandardError
    # Ignoriamo in caso la tabella non abbia ancora registrato sequence
  end

  def import_locations
    puts "📍 1/4 - Importazione Locations..."
    locations_map = {}
    now = Time.current

    # 1. Carichiamo le locations dal CSV primario
    filepath_locs = Rails.root.join("db", "locations", "locations.csv")
    if File.exist?(filepath_locs)
      CSV.foreach(filepath_locs, headers: true, encoding: "UTF-8") do |row|
        name = row["name"].to_s.strip
        next if name.blank?

        # Usiamo il nome downcase come chiave per evitare duplicati
        locations_map[name.downcase] = {
          name: name,
          district: row["district"]&.strip,
          created_at: now,
          updated_at: now
        }
      end
    end

    # 2. Scansioniamo preventivamente le location dal file dei jobs!
    filepath_jobs = Rails.root.join("db", "legacy_data", "legacy_jobs.csv")
    if File.exist?(filepath_jobs)
      CSV.foreach(filepath_jobs, headers: true, encoding: "UTF-8") do |row|
        name = row["location"].to_s.strip
        next if name.blank?

        unless locations_map.key?(name.downcase)
          locations_map[name.downcase] = {
            name: name,
            district: nil, # Non abbiamo il district dai vecchi job
            created_at: now,
            updated_at: now
          }
        end
      end
    end

    Location.upsert_all(locations_map.values, unique_by: [ :name, :district ])
    reset_sqlite_sequence("locations")

    puts "   ✅ Locations a database (incluse quelle extra dei jobs): #{Location.count}"
  end


  def import_contacts
    puts "\n👤 2/4 - Importazione Contatti..."
    filepath = Rails.root.join("db", "legacy_data", "legacy_contacts.csv")
    contacts_data = []
    now = Time.current

    CSV.foreach(filepath, headers: true) do |row|
      is_company = (row["is_company"] == "t")
      first_name = row["first_name"]&.strip
      last_name = row["last_name"]&.strip

      unless is_company
        first_name = "SCONOSCIUTO" if first_name.blank?
        last_name  = "SCONOSCIUTO" if last_name.blank?
      end

      contacts_data << {
        id: row["id"].to_i, # FONDAMENTALE CASTING A INTERO
        kind: is_company ? 1 : 0,
        first_name: first_name,
        last_name: last_name,
        company_name: row["company_name"]&.strip,
        created_at: now,
        updated_at: now
      }
    end

    contacts_data.each_slice(5000) { |batch| Contact.upsert_all(batch) }
    reset_sqlite_sequence("contacts")

    puts "   ✅ Contatti importati: #{Contact.count}"
  end


  def import_jobs_and_itineraries
    puts "\n📸 3/4 - Importazione Lavori e Tappe (JobLocations)..."
    filepath = Rails.root.join("db", "legacy_data", "legacy_jobs.csv")

    location_map = Location.pluck(Arel.sql("LOWER(name)"), :id).to_h

    jobs_data = []
    job_locations_data = []
    now = Time.current

    CSV.foreach(filepath, headers: true) do |row|
      raw_json = row["legacy_data"].to_s.strip
      raw_location = row["location"].to_s.strip

      parsed_json = {}
      begin
        clean_json = raw_json.gsub(/[\x00-\x1F\x7F]/, "")
        parsed_json = JSON.parse(clean_json) if clean_json.present?
      rescue JSON::ParserError
        parsed_json = { "error" => "JSON corrotto", "raw_original" => raw_json }
      end

      start_at = parsed_json["from_time"].present? ? Time.zone.parse(parsed_json["from_time"]) : nil
      end_at = parsed_json["to_time"].present? ? Time.zone.parse(parsed_json["to_time"]) : nil
      with_video = parsed_json["with_video"] == true

      parsed_json["legacy_location_text"] = raw_location if raw_location.present?

      jobs_data << {
        id: row["id"].to_i, # CASTING
        date: row["date"],
        start_at: start_at,
        end_at: end_at,
        description: row["description"]&.strip,
        notes: row["notes"]&.strip,
        with_video: with_video,
        legacy_data: parsed_json,
        created_at: row["created_at"] || now,
        updated_at: row["updated_at"] || now
      }

      if raw_location.present?
        matched_location_id = location_map[raw_location.downcase]

        if matched_location_id
          job_locations_data << {
            job_id: row["id"].to_i, # CASTING
            location_id: matched_location_id,
            position: 1,
            created_at: now,
            updated_at: now
          }
        end
      end
    end

    jobs_data.each_slice(3000) { |batch| Job.upsert_all(batch) }
    reset_sqlite_sequence("jobs")

    job_locations_data.each_slice(3000) { |batch| JobLocation.insert_all(batch) }
    reset_sqlite_sequence("job_locations")

    puts "   ✅ Lavori importati: #{Job.count}"
    puts "   ✅ Tappe (JobLocations) collegate: #{JobLocation.count}"
  end


  def import_participations
    puts "\n🔗 4/4 - Importazione Partecipazioni (Pivot)..."
    filepath = Rails.root.join("db", "legacy_data", "legacy_participations.csv")

    # Pre-carichiamo ID validi in RAM per evitare ForeignKey constraints failure
    valid_job_ids = Job.pluck(:id).to_set
    valid_contact_ids = Contact.pluck(:id).to_set

    participations_data = []
    skipped_count = 0
    now = Time.current

    CSV.foreach(filepath, headers: true) do |row|
      job_id = row["job_id"].to_i
      contact_id = row["contact_id"].to_i

      # Salviamo la pivot SOLO SE il job e il contact esistono realmente!
      if valid_job_ids.include?(job_id) && valid_contact_ids.include?(contact_id)
        participations_data << {
          job_id: job_id,
          contact_id: contact_id,
          role: row["role"]&.strip || "unknown",
          created_at: now,
          updated_at: now
        }
      else
        skipped_count += 1
      end
    end

    participations_data.each_slice(5000) do |batch|
      Participation.insert_all(batch, unique_by: [ :job_id, :contact_id, :role ])
    end
    reset_sqlite_sequence("participations")

    puts "   ✅ Partecipazioni valide importate: #{Participation.count}"
    puts "   ⚠️ Partecipazioni orfane ignorate: #{skipped_count}" if skipped_count > 0
  end
end
