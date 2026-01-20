class AddRoleToSignupRequests < ActiveRecord::Migration[8.0]
  def change
    add_reference :signup_requests, :role, null: false, foreign_key: true
  end
end
