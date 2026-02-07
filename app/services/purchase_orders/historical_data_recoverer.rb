class PurchaseOrders::HistoricalDataRecoverer < BaseService
  attr_reader :last_order_data

  def initialize(enterprise:, customer_id:)
    super()
    @enterprise = enterprise
    @customer_id = customer_id
    @last_order_data = {}
  end

  def call
    @last_order_data = {
      last_notes: last_order&.notes
    }

    set_as_valid!
  rescue => e
    add_error(e.message)
    set_as_invalid!
  end

  private

  def last_order
    @last_order ||= @enterprise
      .purchase_orders
      .where(sourceable_type: "Sale")
      .where(sourceable_id: Sale.where(customer_id: @customer_id).select(:id))
      .where.not(status: :cancelled)
      .order(created_at: :desc)
      .first
  end
end
