class CreateEnterpriseSettings < ActiveRecord::Migration[8.0]
  def change
    create_table :enterprise_settings do |t|
      t.references :enterprise, null: false, foreign_key: true, index: { unique: true }
      t.boolean :generate_purchase_order_from_sale, default: false, null: false
      t.timestamps
    end
  end
end
