class CreateUbigeos < ActiveRecord::Migration[8.1]
  def change
    create_table :ubigeos do |t|
      t.string :code, null: false, limit: 6
      t.string :name, null: false
      t.string :level, null: false  # department, province, district
      t.references :parent, foreign_key: { to_table: :ubigeos }

      t.timestamps
    end

    add_index :ubigeos, :code, unique: true
    add_index :ubigeos, :level
    add_index :ubigeos, [ :level, :parent_id ]
  end
end
