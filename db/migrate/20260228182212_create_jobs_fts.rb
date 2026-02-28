class CreateJobsFts < ActiveRecord::Migration[8.1]
  def up
    create_virtual_table :jobs_fts, :fts5, [
                           "description", "notes", "legacy_data", "content='jobs'", "content_rowid='id'"
                         ]

    execute <<-SQL
      CREATE TRIGGER jobs_ai AFTER INSERT ON jobs BEGIN
        INSERT INTO jobs_fts(rowid, description, notes, legacy_data)
        VALUES (new.id, new.description, new.notes, new.legacy_data);
      END;
    SQL

    execute <<-SQL
      CREATE TRIGGER jobs_ad AFTER DELETE ON jobs BEGIN
        INSERT INTO jobs_fts(jobs_fts, rowid, description, notes, legacy_data)
        VALUES('delete', old.id, old.description, old.notes, old.legacy_data);
      END;
    SQL

    execute <<-SQL
      CREATE TRIGGER jobs_au AFTER UPDATE ON jobs BEGIN
        INSERT INTO jobs_fts(jobs_fts, rowid, description, notes, legacy_data)
        VALUES('delete', old.id, old.description, old.notes, old.legacy_data);

        INSERT INTO jobs_fts(rowid, description, notes, legacy_data)
        VALUES (new.id, new.description, new.notes, new.legacy_data);
      END;
    SQL
  end

  def down
    execute "DROP TRIGGER IF EXISTS jobs_ai;"
    execute "DROP TRIGGER IF EXISTS jobs_ad;"
    execute "DROP TRIGGER IF EXISTS jobs_au;"
    drop_virtual_table :jobs_fts
  end
end
