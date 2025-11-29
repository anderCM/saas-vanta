class CreateUserEnterprises < ActiveRecord::Migration[8.1]
  def change
    create_table :user_enterprises do |t|
      t.references :user, null: false, foreign_key: true
      t.references :enterprise, null: false, foreign_key: true

      t.timestamps
    end
    add_index :user_enterprises, [ :user_id, :enterprise_id ], unique: true
  end
end
