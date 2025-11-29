class CreateEnterprises < ActiveRecord::Migration[8.1]
  def change
    create_table :enterprises do |t|
      t.bigint :tax_id, null: false, index: { unique: true }
      t.string :social_reason, null: false
      t.string :comercial_name, null: false
      t.string :address, null: false
      t.string :email, null: false
      t.string :subdomain, null: false, index: { unique: true }
      t.string :phone_number
      t.string :logo
      t.string :status, null: false, index: true

      t.timestamps
    end
  end
end
