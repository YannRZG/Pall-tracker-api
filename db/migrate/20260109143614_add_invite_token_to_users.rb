class AddInviteTokenToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :invite_token, :string
    add_column :users, :invited_at, :datetime
  end
end
