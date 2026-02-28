class CreateLocation < ActiveRecord::Migration[8.1]
  def change
    create_table :locations do |t|
      t.string :category, null: false, default: ""  # Es. "Campo", "Rio Terà"
      t.string :name,     null: false               # Es. "San Polo", "Canal Grande"
      t.string :district, null: false, default: ""  # Es. "San Polo", "Dorsoduro"
      t.string :city,     null: false, default: "Venezia"

      t.virtual :full_address,
                type: :string,
                as: "TRIM(category || ' ' || name || CASE WHEN district != '' THEN ' (' || city || ' - ' || district || ')' ELSE ' (' || city || ')' END)",
                stored: false

      t.timestamps
    end
    add_index :locations, [ :category, :name, :district, :city ], unique: true, name: "idx_locations_unique_identity"
  end
end
