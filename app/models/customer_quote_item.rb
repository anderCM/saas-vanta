class CustomerQuoteItem < ApplicationRecord
  # Associations
  belongs_to :customer_quote
  belongs_to :product

  # Delegations
  delegate :name, :sku, :unit, to: :product

  # Validations
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :unit_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :product_id, uniqueness: { scope: :customer_quote_id, message: "ya esta en la cotizacion" }

  # Callbacks
  before_save :calculate_total

  def unit_label
    product.unit.upcase
  end

  private

  def calculate_total
    self.total = (quantity || 0) * (unit_price || 0)
  end
end
