class CreateRoles < ActiveRecord::Migration[8.1]
  def change
    create_table :roles do |t|
      t.string :name, null: false
      t.string :slug, null: false, index: { unique: true }
      t.string :description

      t.timestamps
    end
  end
end
