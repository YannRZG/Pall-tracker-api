class CreateCompanies < ActiveRecord::Migration[8.0]
  def change
    create_table :companies do |t|
      t.string :name
      t.string :street
      t.string :zipcode
      t.string :country
      t.references :role, foreign_key: true
      t.boolean :approved, default: false
      t.datetime :approved_at

      t.timestamps
    end
  end
end
