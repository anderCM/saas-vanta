class PurchaseOrderItem < ApplicationRecord
  include LineItemCalculable

  belongs_to :purchase_order

  delegate :name, :sku, :unit, to: :product, prefix: true, allow_nil: true

  validates :product_id, uniqueness: { scope: :purchase_order_id, message: "ya fue agregado a esta orden" }

  def unit_label
    Product.units[product_unit]&.upcase || product_unit&.upcase
  end
end
