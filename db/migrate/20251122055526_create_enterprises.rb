class CreateEnterprises < ActiveRecord::Migration[8.1]
  def change
    create_table :enterprises do |t|
      t.bigint :tax_id
      t.string :enterprise_type, null: false
      t.string :social_reason
      t.string :comercial_name, null: false
      t.string :address
      t.string :email
      t.string :subdomain, null: false, index: { unique: true }
      t.string :phone_number
      t.string :logo
      t.string :status, null: false, index: true

      t.timestamps
    end
    add_index :enterprises, :tax_id, unique: true, where: "tax_id IS NOT NULL", name: 'idx_enterprises_on_tax_id_unq_not_null'
  end
end
