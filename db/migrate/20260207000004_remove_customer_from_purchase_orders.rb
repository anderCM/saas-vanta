class RemoveCustomerFromPurchaseOrders < ActiveRecord::Migration[8.0]
  def change
    remove_reference :purchase_orders, :customer, foreign_key: true
  end
end
