class CreateParticipationsFts < ActiveRecord::Migration[8.1]
  def up
    create_virtual_table :participations_fts, :fts5, [
                           "title", "role", "content='participations'", "content_rowid='id'"
                         ]

    execute <<-SQL
      CREATE TRIGGER participations_ai AFTER INSERT ON participations BEGIN
        INSERT INTO participations_fts(rowid, title, role)
        VALUES (new.id, new.title, new.role);
      END;
    SQL

    execute <<-SQL
      CREATE TRIGGER participations_ad AFTER DELETE ON participations BEGIN
        INSERT INTO participations_fts(participations_fts, rowid, title, role)
        VALUES('delete', old.id, old.title, old.role);
      END;
    SQL

    execute <<-SQL
      CREATE TRIGGER participations_au AFTER UPDATE ON participations BEGIN
        INSERT INTO participations_fts(participations_fts, rowid, title, role)
        VALUES('delete', old.id, old.title, old.role);

        INSERT INTO participations_fts(rowid, title, role)
        VALUES (new.id, new.title, new.role);
      END;
    SQL

    execute <<-SQL
      INSERT INTO participations_fts(rowid, title, role)
      SELECT id, title, role FROM participations;
    SQL
  end

  def down
    execute "DROP TRIGGER IF EXISTS participations_ai;"
    execute "DROP TRIGGER IF EXISTS participations_ad;"
    execute "DROP TRIGGER IF EXISTS participations_au;"
    drop_virtual_table :participations_fts
  end
end
