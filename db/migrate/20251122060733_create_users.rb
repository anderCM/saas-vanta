class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :first_name, null: false
      t.string :first_last_name, null: false
      t.string :second_last_name
      t.string :phone_number
      t.string :status, null: false, index: true
      t.string :platform_role, null: false, index: true

      t.string :email_address, null: false, index: { unique: true }
      t.string :password_digest
      t.string :invitation_token, index: { unique: true }
      t.datetime :invitation_sent_at
      t.datetime :invitation_accepted_at

      t.timestamps
    end
  end
end
