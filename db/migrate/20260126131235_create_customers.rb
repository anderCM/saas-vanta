class CreateCustomers < ActiveRecord::Migration[8.1]
  def change
    create_table :customers do |t|
      t.references :enterprise, null: false, foreign_key: true
      t.string :tax_id
      t.string :tax_id_type, null: false, default: 'ruc'
      t.string :name, null: false
      t.string :address
      t.string :phone_number
      t.string :email
      t.decimal :credit_limit, precision: 10, scale: 2, null: false, default: 0.0
      t.integer :payment_terms, null: false, default: 0

      t.timestamps
    end
    add_index :customers, [ :enterprise_id, :tax_id ], unique: true, where: "tax_id IS NOT NULL", name: 'idx_customers_on_tax_id_unq_not_null'
  end
end
