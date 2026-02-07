class CreateSales < ActiveRecord::Migration[8.0]
  def change
    create_table :sales do |t|
      t.string :code, null: false
      t.references :enterprise, null: false, foreign_key: true
      t.references :customer, null: false, foreign_key: true
      t.references :created_by, null: false, foreign_key: { to_table: :users }
      t.references :seller, null: false, foreign_key: { to_table: :users }
      t.references :destination, foreign_key: { to_table: :ubigeos }
      t.string :status, null: false, default: "pending"
      t.date :issue_date, null: false
      t.decimal :subtotal, precision: 10, scale: 2, default: 0.0
      t.decimal :tax, precision: 10, scale: 2, default: 0.0
      t.decimal :total, precision: 10, scale: 2, default: 0.0
      t.text :notes
      t.references :sourceable, polymorphic: true

      t.timestamps
    end

    add_index :sales, [ :enterprise_id, :code ], unique: true
    add_index :sales, :status
    add_index :sales, :issue_date
  end
end
