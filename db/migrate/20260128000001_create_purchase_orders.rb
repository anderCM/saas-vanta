class CreatePurchaseOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :purchase_orders do |t|
      t.references :enterprise, null: false, foreign_key: true
      t.references :provider, null: false, foreign_key: true
      t.references :created_by, null: false, foreign_key: { to_table: :users }
      t.references :destination, foreign_key: { to_table: :ubigeos }
      t.references :customer, foreign_key: true

      t.string :code, null: false
      t.string :status, null: false, default: "draft"
      t.date :issue_date, null: false
      t.date :expected_date

      t.decimal :subtotal, precision: 10, scale: 2, null: false, default: 0
      t.decimal :tax, precision: 10, scale: 2, null: false, default: 0
      t.decimal :total, precision: 10, scale: 2, null: false, default: 0

      t.text :notes

      t.timestamps
    end

    add_index :purchase_orders, [ :enterprise_id, :code ], unique: true
    add_index :purchase_orders, :status
    add_index :purchase_orders, :issue_date
  end
end
