class Job < ApplicationRecord
  include FtsSearchable, JsonAttributesAccessor

  broadcasts_refreshes          # turbo

  has_many :job_locations, dependent: :destroy
  has_many :locations, through: :job_locations

  accepts_nested_attributes_for :job_locations, allow_destroy: true

  has_many :participations, dependent: :destroy
  has_many :contacts, through: :participations

  accepts_nested_attributes_for :participations, allow_destroy: true

  has_many :photographer_participations, -> { where(role: Participation::ROLES[:photographer]) }, class_name: "Participation"
  has_many :photographers, through: :photographer_participations, source: :contact

  has_many :client_participations, -> { where(role: Participation::ROLES[:client]) }, class_name: "Participation"
  has_many :clients, through: :client_participations, source: :contact

  has_many :subject_participations, -> { where(role: Participation::ROLES[:subject]) }, class_name: "Participation"
  has_many :subjects, through: :subject_participations, source: :contact

  validates :date, presence: true

  scope :with_video, -> { where(with_video: true) }
  scope :recent, -> { order(date: :desc) }

  json_accessor :legacy_data, :from_time, :to_time, :legacy_location_text

  def legacy_from_time
    return nil if from_time.blank?
    Time.parse(from_time) rescue nil
  end

  def legacy_to_time
    return nil if to_time.blank?
    Time.parse(to_time) rescue nil
  end

  def display_location
    return locations.map(&:name).join(" → ") if locations.any?

    legacy_location_text.presence || "Location sconosciuta"
  end

  def self.global_search(query)
    return all if query.blank?

    # 1. Spezziamo la query in termini singoli (rimuovendo spazi extra)
    terms = query.to_s.strip.split(/\s+/)

    # Inizializziamo la variabile che conterrà gli ID finali
    intersected_job_ids = nil

    # 2. Iteriamo su ogni singola parola della ricerca
    terms.each do |term|
      # Troviamo tutti i Job associati a QUESTO termine in tutte le tabelle
      job_ids = search_text(term).pluck(:id)

      loc_ids = Location.search_text(term).select(:id)
      job_ids_from_loc = joins(:job_locations).where(job_locations: { location_id: loc_ids }).pluck(:id)

      contact_ids = Contact.search_text(term).select(:id)
      job_ids_from_contacts = joins(:participations).where(participations: { contact_id: contact_ids }).pluck(:id)

      participation_ids = Participation.search_text(term).select(:id)
      job_ids_from_parts = joins(:participations).where(participations: { id: participation_ids }).pluck(:id)

      # Uniamo tutti gli ID trovati per questo singolo termine
      term_job_ids = (job_ids + job_ids_from_loc + job_ids_from_contacts + job_ids_from_parts).uniq

      # 3. INTERSEZIONE (AND logico)
      # Se è il primo giro, salviamo gli ID.
      # Dai giri successivi, manteniamo solo gli ID che matchano anche il nuovo termine.
      if intersected_job_ids.nil?
        intersected_job_ids = term_job_ids
      else
        intersected_job_ids = intersected_job_ids & term_job_ids
      end

      # Ottimizzazione: se a un certo punto l'intersezione è vuota, inutile cercare gli altri termini!
      break if intersected_job_ids.empty?
    end

    # 4. Restituiamo la query finale ordinata
    where(id: intersected_job_ids).order(date: :desc)
  end
end
