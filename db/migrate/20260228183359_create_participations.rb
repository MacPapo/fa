class CreateParticipations < ActiveRecord::Migration[8.1]
  def change
    create_table :participations do |t|
      t.references :job, null: false, foreign_key: true
      t.references :contact, null: false, foreign_key: true

      t.string :title
      t.string :role, null: false

      t.timestamps
    end

    add_index :participations, [ :job_id, :contact_id, :role ], unique: true, name: "idx_participations_unique_role"
  end
end
