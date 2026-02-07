class CustomerQuoteItem < ApplicationRecord
  include LineItemCalculable

  belongs_to :customer_quote

  delegate :name, :sku, :unit, to: :product

  validates :product_id, uniqueness: { scope: :customer_quote_id, message: "ya esta en la cotizacion" }
end
