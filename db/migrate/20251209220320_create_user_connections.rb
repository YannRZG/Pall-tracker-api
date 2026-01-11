class CreateUserConnections < ActiveRecord::Migration[8.0]
  def change
    create_table :user_connections do |t|
      t.references :shipper, null: false, foreign_key: { to_table: :users }
      t.references :carrier, null: false, foreign_key: { to_table: :users }
      t.references :recipient, null: false, foreign_key: { to_table: :users }


      t.timestamps
    end
  end
end
