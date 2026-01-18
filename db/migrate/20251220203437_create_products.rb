class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.references :enterprise, null: false, foreign_key: true
      t.references :provider, foreign_key: true
      t.string :name, null: false
      t.string :description
      t.string :sku
      t.string :source_type, null: false
      t.string :unit, null: false
      t.integer :units_per_package
      t.decimal :buy_price, null: false
      t.decimal :sell_cash_price, null: false
      t.decimal :sell_credit_price, null: false
      t.integer :stock
      t.string :status, null: false, index: true
      t.timestamps
    end
    add_index :products, [ :enterprise_id, :sku ], unique: true, where: "sku IS NOT NULL", name: 'idx_products_on_sku_unq_not_null'
  end
end
