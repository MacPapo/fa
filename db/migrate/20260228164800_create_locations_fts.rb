class CreateLocationsFts < ActiveRecord::Migration[8.1]
  def up
    create_virtual_table :locations_fts, :fts5, [
                           "category", "name", "district", "city", "content='locations'", "content_rowid='id'"
                         ]

    execute <<-SQL
      CREATE TRIGGER locations_ai AFTER INSERT ON locations BEGIN
        INSERT INTO locations_fts(rowid, category, name, district, city)
        VALUES (new.id, new.category, new.name, new.district, new.city);
      END;
    SQL

    execute <<-SQL
      CREATE TRIGGER locations_ad AFTER DELETE ON locations BEGIN
        INSERT INTO locations_fts(locations_fts, rowid, category, name, district, city)
        VALUES('delete', old.id, old.category, old.name, old.district, old.city);
      END;
    SQL

    execute <<-SQL
      CREATE TRIGGER locations_au AFTER UPDATE ON locations BEGIN
        INSERT INTO locations_fts(locations_fts, rowid, category, name, district, city)
        VALUES('delete', old.id, old.category, old.name, old.district, old.city);
        INSERT INTO locations_fts(rowid, category, name, district, city)
        VALUES (new.id, new.category, new.name, new.district, new.city);
      END;
    SQL
  end

  def down
    execute "DROP TRIGGER IF EXISTS locations_ai;"
    execute "DROP TRIGGER IF EXISTS locations_ad;"
    execute "DROP TRIGGER IF EXISTS locations_au;"

    drop_virtual_table :locations_fts
  end
end
