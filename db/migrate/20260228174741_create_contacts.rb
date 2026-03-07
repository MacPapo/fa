class CreateContacts < ActiveRecord::Migration[8.1]
  def change
    create_table :contacts do |t|
      # 0 = Privato (Person), 1 = Azienda/Studio (Company)
      t.integer :kind, null: false, default: 0

      # Dati B2C (Persone fisiche)
      t.string :first_name
      t.string :last_name
      t.string :known_as

      # Dati B2B (Aziende)
      t.string :company_name
      t.string :vat_number      # Partita IVA
      t.string :sdi_code        # Codice Univoco Fatturazione (7 caratteri)

      # Dati Condivisi
      t.string :tax_id          # Codice Fiscale (vale per entrambi)
      t.string :email
      t.string :phone
      t.text   :notes

      t.virtual :display_name,
                type: :string,
                as: "TRIM(COALESCE(NULLIF(TRIM(CASE WHEN kind = 1 THEN company_name ELSE '' END), ''), NULLIF(TRIM(COALESCE(first_name, '') || ' ' || COALESCE(last_name, '')), ''), '') || CASE WHEN known_as IS NOT NULL AND known_as != '' THEN ' (' || known_as || ')' ELSE '' END)",
                stored: false

      t.timestamps
    end

    add_index :contacts, :email, unique: true, where: "email IS NOT NULL AND email != ''"
    add_index :contacts, :tax_id, unique: true, where: "tax_id IS NOT NULL AND tax_id != ''"
    add_index :contacts, :vat_number, unique: true, where: "vat_number IS NOT NULL AND vat_number != ''"
  end
end
