class RenameSettingAndAddDeliveryToPurchaseOrders < ActiveRecord::Migration[8.0]
  def change
    rename_column :enterprise_settings, :generate_purchase_order_from_sale, :dropshipping_enabled

    add_reference :purchase_orders, :sourceable, polymorphic: true, null: true
    add_column :purchase_orders, :delivery_address, :string
  end
end
