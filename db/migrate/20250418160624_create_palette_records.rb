class CreatePaletteRecords < ActiveRecord::Migration[8.0]
  def change
    create_table :palette_records do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :week
      t.datetime :date
      t.string :transport
      t.string :loading_point
      t.string :delivery_point
      t.integer :loaded
      t.integer :rendered
      t.integer :delivered
      t.integer :returned
      t.integer :due
      t.string :comment

      t.timestamps
    end
  end
end
