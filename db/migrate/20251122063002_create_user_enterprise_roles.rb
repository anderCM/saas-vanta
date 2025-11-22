class CreateUserEnterpriseRoles < ActiveRecord::Migration[8.1]
  def change
    create_table :user_enterprise_roles do |t|
      t.references :user_enterprise, null: false, foreign_key: true
      t.references :role, null: false, foreign_key: true

      t.timestamps
    end
    add_index :user_enterprise_roles, [ :user_enterprise_id, :role_id ], unique: true, name: 'index_uer_on_ue_id_and_role_id'
  end
end
