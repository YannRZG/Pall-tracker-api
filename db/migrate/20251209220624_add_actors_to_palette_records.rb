class AddActorsToPaletteRecords < ActiveRecord::Migration[8.0]
  def change
    add_reference :palette_records, :shipper, null: false, foreign_key: { to_table: :users }
    add_reference :palette_records, :carrier, null: false, foreign_key: { to_table: :users }
    add_reference :palette_records, :recipient, null: false, foreign_key: { to_table: :users }
  end
end
