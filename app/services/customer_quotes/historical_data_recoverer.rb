class CustomerQuotes::HistoricalDataRecoverer < BaseService
  attr_reader :last_quote_data

  def initialize(enterprise:, customer_id:)
    super()
    @enterprise = enterprise
    @customer_id = customer_id
    @last_quote_data = {}
  end

  def call
    @last_quote_data = {
      last_notes: last_quote&.notes
    }

    set_as_valid!
  rescue => e
    add_error(e.message)
    set_as_invalid!
  end

  private

  def last_quote
    @last_quote ||= @enterprise
      .customer_quotes
      .where(customer_id: @customer_id)
      .where.not(status: :rejected)
      .order(created_at: :desc)
      .first
  end
end
