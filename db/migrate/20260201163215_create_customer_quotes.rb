class CreateCustomerQuotes < ActiveRecord::Migration[8.1]
  def change
    create_table :customer_quotes do |t|
      t.references :enterprise, null: false, foreign_key: true
      t.references :customer, null: false, foreign_key: true
      t.references :created_by, null: false, foreign_key: { to_table: :users }
      t.references :seller, null: false, foreign_key: { to_table: :users }
      t.references :destination, foreign_key: { to_table: :ubigeos }

      t.string :code, null: false
      t.string :status, null: false, default: "pending"
      t.date :issue_date, null: false
      t.date :expiration_date

      t.decimal :subtotal, precision: 10, scale: 2, default: 0.0
      t.decimal :tax, precision: 10, scale: 2, default: 0.0
      t.decimal :total, precision: 10, scale: 2, default: 0.0

      t.text :notes

      t.timestamps
    end
    add_index :customer_quotes, [ :enterprise_id, :code ], unique: true
    add_index :customer_quotes, :status
    add_index :customer_quotes, :issue_date
  end
end
