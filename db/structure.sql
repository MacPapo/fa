CREATE TABLE IF NOT EXISTS "schema_migrations" ("version" varchar NOT NULL PRIMARY KEY);
CREATE TABLE IF NOT EXISTS "ar_internal_metadata" ("key" varchar NOT NULL PRIMARY KEY, "value" varchar, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL);
CREATE TABLE IF NOT EXISTS "locations" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "category" varchar DEFAULT '' NOT NULL, "name" varchar NOT NULL, "district" varchar DEFAULT '' NOT NULL, "city" varchar DEFAULT 'Venezia' NOT NULL, "full_address" varchar GENERATED ALWAYS AS (TRIM(category || ' ' || name || CASE WHEN district != '' THEN ' (' || city || ' - ' || district || ')' ELSE ' (' || city || ')' END)) VIRTUAL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL);
CREATE UNIQUE INDEX "idx_locations_unique_identity" ON "locations" ("category", "name", "district", "city") /*application='Fa'*/;
CREATE VIRTUAL TABLE locations_fts USING fts5 (category, name, district, city, content='locations', content_rowid='id')
/* locations_fts(category,name,district,city) */;
CREATE TABLE IF NOT EXISTS 'locations_fts_data'(id INTEGER PRIMARY KEY, block BLOB);
CREATE TABLE IF NOT EXISTS 'locations_fts_idx'(segid, term, pgno, PRIMARY KEY(segid, term)) WITHOUT ROWID;
CREATE TABLE IF NOT EXISTS 'locations_fts_docsize'(id INTEGER PRIMARY KEY, sz BLOB);
CREATE TABLE IF NOT EXISTS 'locations_fts_config'(k PRIMARY KEY, v) WITHOUT ROWID;
CREATE TRIGGER locations_ai AFTER INSERT ON locations BEGIN
        INSERT INTO locations_fts(rowid, category, name, district, city)
        VALUES (new.id, new.category, new.name, new.district, new.city);
      END;
CREATE TRIGGER locations_ad AFTER DELETE ON locations BEGIN
        INSERT INTO locations_fts(locations_fts, rowid, category, name, district, city)
        VALUES('delete', old.id, old.category, old.name, old.district, old.city);
      END;
CREATE TRIGGER locations_au AFTER UPDATE ON locations BEGIN
        INSERT INTO locations_fts(locations_fts, rowid, category, name, district, city)
        VALUES('delete', old.id, old.category, old.name, old.district, old.city);
        INSERT INTO locations_fts(rowid, category, name, district, city)
        VALUES (new.id, new.category, new.name, new.district, new.city);
      END;
CREATE TABLE IF NOT EXISTS "contacts" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "kind" integer DEFAULT 0 NOT NULL, "first_name" varchar, "last_name" varchar, "known_as" varchar, "company_name" varchar, "vat_number" varchar, "sdi_code" varchar, "tax_id" varchar, "email" varchar, "phone" varchar, "notes" text, "display_name" varchar GENERATED ALWAYS AS (CASE WHEN kind = 1 THEN COALESCE(company_name, '') ELSE TRIM(COALESCE(first_name, '') || ' ' || COALESCE(last_name, '') || CASE WHEN known_as IS NOT NULL AND known_as != '' THEN ' (' || known_as || ')' ELSE '' END) END) VIRTUAL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL);
CREATE UNIQUE INDEX "index_contacts_on_email" ON "contacts" ("email") WHERE email IS NOT NULL AND email != '' /*application='Fa'*/;
CREATE UNIQUE INDEX "index_contacts_on_tax_id" ON "contacts" ("tax_id") WHERE tax_id IS NOT NULL AND tax_id != '' /*application='Fa'*/;
CREATE UNIQUE INDEX "index_contacts_on_vat_number" ON "contacts" ("vat_number") WHERE vat_number IS NOT NULL AND vat_number != '' /*application='Fa'*/;
CREATE VIRTUAL TABLE contacts_fts USING fts5 (first_name, last_name, known_as, company_name, email, phone, vat_number, tax_id, notes, content='contacts', content_rowid='id')
/* contacts_fts(first_name,last_name,known_as,company_name,email,phone,vat_number,tax_id,notes) */;
CREATE TABLE IF NOT EXISTS 'contacts_fts_data'(id INTEGER PRIMARY KEY, block BLOB);
CREATE TABLE IF NOT EXISTS 'contacts_fts_idx'(segid, term, pgno, PRIMARY KEY(segid, term)) WITHOUT ROWID;
CREATE TABLE IF NOT EXISTS 'contacts_fts_docsize'(id INTEGER PRIMARY KEY, sz BLOB);
CREATE TABLE IF NOT EXISTS 'contacts_fts_config'(k PRIMARY KEY, v) WITHOUT ROWID;
CREATE TRIGGER contacts_ai AFTER INSERT ON contacts BEGIN
        INSERT INTO contacts_fts(rowid, first_name, last_name, known_as, company_name, email, phone, vat_number, tax_id, notes)
        VALUES (new.id, new.first_name, new.last_name, new.known_as, new.company_name, new.email, new.phone, new.vat_number, new.tax_id, new.notes);
      END;
CREATE TRIGGER contacts_ad AFTER DELETE ON contacts BEGIN
        INSERT INTO contacts_fts(contacts_fts, rowid, first_name, last_name, known_as, company_name, email, phone, vat_number, tax_id, notes)
        VALUES('delete', old.id, old.first_name, old.last_name, old.known_as, old.company_name, old.email, old.phone, old.vat_number, old.tax_id, old.notes);
      END;
CREATE TRIGGER contacts_au AFTER UPDATE ON contacts BEGIN
        INSERT INTO contacts_fts(contacts_fts, rowid, first_name, last_name, known_as, company_name, email, phone, vat_number, tax_id, notes)
        VALUES('delete', old.id, old.first_name, old.last_name, old.known_as, old.company_name, old.email, old.phone, old.vat_number, old.tax_id, old.notes);

        INSERT INTO contacts_fts(rowid, first_name, last_name, known_as, company_name, email, phone, vat_number, tax_id, notes)
        VALUES (new.id, new.first_name, new.last_name, new.known_as, new.company_name, new.email, new.phone, new.vat_number, new.tax_id, new.notes);
      END;
INSERT INTO "schema_migrations" (version) VALUES
('20260228175407'),
('20260228174741'),
('20260228164800'),
('20260228164617');

