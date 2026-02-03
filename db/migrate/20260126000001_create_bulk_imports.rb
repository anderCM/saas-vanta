class CreateBulkImports < ActiveRecord::Migration[8.1]
  def change
    create_table :bulk_imports do |t|
      t.references :enterprise, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :resource_type, null: false
      t.string :status, null: false, default: "pending"
      t.string :original_filename
      t.integer :total_rows, default: 0
      t.integer :successful_rows, default: 0
      t.integer :failed_rows, default: 0
      t.jsonb :results, default: {}
      t.datetime :started_at
      t.datetime :completed_at
      t.timestamps
    end

    add_index :bulk_imports, :resource_type
    add_index :bulk_imports, :status
    add_index :bulk_imports, [ :enterprise_id, :resource_type ]
  end
end
