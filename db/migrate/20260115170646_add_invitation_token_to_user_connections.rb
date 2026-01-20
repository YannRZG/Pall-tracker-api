class AddInvitationTokenToUserConnections < ActiveRecord::Migration[8.0]
  def change
    add_column :user_connections, :invitation_token, :string
    add_index :user_connections, :invitation_token, unique: true
  end
end
