class CreateProviders < ActiveRecord::Migration[8.1]
  def change
    create_table :providers do |t|
      t.references :enterprise, null: false, foreign_key: true
      t.string :tax_id
      t.string :name, null: false
      t.string :phone_number
      t.string :email
      t.timestamps
    end
    add_index :providers, [ :enterprise_id, :tax_id ], unique: true, where: "tax_id IS NOT NULL", name: 'idx_providers_on_tax_id_unq_not_null'
  end
end
