class RemoveRoleFromInvitations < ActiveRecord::Migration[8.0]
  def change
    remove_column :invitations, :role, :integer
  end
end
