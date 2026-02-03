class PurchaseOrderItem < ApplicationRecord
  # Associations
  belongs_to :purchase_order
  belongs_to :product

  # Validations
  validates :quantity, presence: true, numericality: { greater_than: 0, only_integer: true }
  validates :unit_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :product_id, uniqueness: { scope: :purchase_order_id, message: "ya fue agregado a esta orden" }

  # Callbacks
  before_save :calculate_total

  # Delegations
  delegate :name, :sku, :unit, to: :product, prefix: true, allow_nil: true

  def unit_label
    Product.units[product_unit]&.upcase || product_unit&.upcase
  end

  private

  def calculate_total
    self.total = (quantity || 0) * (unit_price || 0)
  end
end
