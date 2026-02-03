class CreateCustomerQuoteItems < ActiveRecord::Migration[8.1]
  def change
    create_table :customer_quote_items do |t|
      t.references :customer_quote, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true

      t.decimal :quantity, precision: 10, scale: 2, default: 0.0
      t.decimal :unit_price, precision: 10, scale: 2, default: 0.0
      t.decimal :total, precision: 10, scale: 2, default: 0.0

      t.timestamps
    end
    add_index :customer_quote_items, [ :customer_quote_id, :product_id ], unique: true
  end
end
