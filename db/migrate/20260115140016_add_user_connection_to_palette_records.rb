class AddUserConnectionToPaletteRecords < ActiveRecord::Migration[8.0]
  def change
    add_reference :palette_records, :user_connection, null: false, foreign_key: true
  end
end
