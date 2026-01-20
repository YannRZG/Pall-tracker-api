class CreateUserConnections < ActiveRecord::Migration[7.0]
  def change
    create_table :user_connections do |t|
      t.references :requester, null: false, foreign_key: { to_table: :companies }
      t.references :receiver,  null: false, foreign_key: { to_table: :companies }
      t.integer :status,       default: 0, null: false

      t.timestamps
    end

    add_index :user_connections, [ :requester_id, :receiver_id ], unique: true
  end
end
