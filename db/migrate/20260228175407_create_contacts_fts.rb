class CreateContactsFts < ActiveRecord::Migration[8.1]
  def up
    create_virtual_table :contacts_fts, :fts5, [
                           "first_name", "last_name", "known_as", "company_name", "email", "phone", "vat_number", "tax_id", "notes", "content='contacts'", "content_rowid='id'"
                         ]

    execute <<-SQL
      CREATE TRIGGER contacts_ai AFTER INSERT ON contacts BEGIN
        INSERT INTO contacts_fts(rowid, first_name, last_name, known_as, company_name, email, phone, vat_number, tax_id, notes)
        VALUES (new.id, new.first_name, new.last_name, new.known_as, new.company_name, new.email, new.phone, new.vat_number, new.tax_id, new.notes);
      END;
    SQL

    execute <<-SQL
      CREATE TRIGGER contacts_ad AFTER DELETE ON contacts BEGIN
        INSERT INTO contacts_fts(contacts_fts, rowid, first_name, last_name, known_as, company_name, email, phone, vat_number, tax_id, notes)
        VALUES('delete', old.id, old.first_name, old.last_name, old.known_as, old.company_name, old.email, old.phone, old.vat_number, old.tax_id, old.notes);
      END;
    SQL

    execute <<-SQL
      CREATE TRIGGER contacts_au AFTER UPDATE ON contacts BEGIN
        INSERT INTO contacts_fts(contacts_fts, rowid, first_name, last_name, known_as, company_name, email, phone, vat_number, tax_id, notes)
        VALUES('delete', old.id, old.first_name, old.last_name, old.known_as, old.company_name, old.email, old.phone, old.vat_number, old.tax_id, old.notes);

        INSERT INTO contacts_fts(rowid, first_name, last_name, known_as, company_name, email, phone, vat_number, tax_id, notes)
        VALUES (new.id, new.first_name, new.last_name, new.known_as, new.company_name, new.email, new.phone, new.vat_number, new.tax_id, new.notes);
      END;
    SQL
  end

  def down
    execute "DROP TRIGGER IF EXISTS contacts_ai;"
    execute "DROP TRIGGER IF EXISTS contacts_ad;"
    execute "DROP TRIGGER IF EXISTS contacts_au;"
    drop_virtual_table :contacts_fts
  end
end
