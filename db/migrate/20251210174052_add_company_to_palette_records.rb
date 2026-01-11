class AddCompanyToPaletteRecords < ActiveRecord::Migration[8.0]
  def change
    add_reference :palette_records, :company, null: false, foreign_key: true
  end
end
