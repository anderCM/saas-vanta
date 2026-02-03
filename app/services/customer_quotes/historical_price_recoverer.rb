class CustomerQuotes::HistoricalPriceRecoverer < BaseService
  attr_reader :price_history

  def initialize(enterprise:, customer_id:)
    super()
    @enterprise = enterprise
    @customer_id = customer_id
    @price_history = {}
  end

  def call
    @price_history = fetch_latest_prices

    set_as_valid!
  rescue => e
    add_error(e.message)
    set_as_invalid!
  end

  private

  # Uses PostgreSQL DISTINCT ON to get the most recent price per product
  # across ALL previous quotes for this customer, in a single query.
  #
  # For example, if the customer had:
  #   - Quote 3 (newest): Item2 at S/24
  #   - Quote 2:          Item1 at S/30
  #   - Quote 1 (oldest): Item20 at S/18, Item1 at S/25
  #
  # This returns: { item2_id => 24, item1_id => 30, item20_id => 18 }
  # (Item1 uses S/30 from Quote 2, not S/25 from Quote 1)
  def fetch_latest_prices
    rows = CustomerQuoteItem
      .joins(:customer_quote)
      .where(customer_quotes: { customer_id: @customer_id, enterprise_id: @enterprise.id })
      .where.not(customer_quotes: { status: :rejected })
      .select(
        "DISTINCT ON (customer_quote_items.product_id) " \
        "customer_quote_items.product_id, customer_quote_items.unit_price"
      )
      .order("customer_quote_items.product_id, customer_quotes.created_at DESC")

    rows.each_with_object({}) do |row, hash|
      hash[row.product_id.to_s] = row.unit_price.to_f
    end
  end
end
