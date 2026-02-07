class SaleItem < ApplicationRecord
  include LineItemCalculable

  belongs_to :sale

  delegate :name, :sku, :unit, to: :product

  validates :product_id, uniqueness: { scope: :sale_id, message: "ya fue agregado a esta venta" }
end
