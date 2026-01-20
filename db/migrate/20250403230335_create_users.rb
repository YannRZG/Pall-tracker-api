class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :password_digest, null: false
      t.integer :function, default: 0
      t.boolean :admin, default: false
      t.references :company, foreign_key: true
      t.timestamps
    end
  end
end
