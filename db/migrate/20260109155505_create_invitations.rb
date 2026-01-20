class CreateInvitations < ActiveRecord::Migration[8.0]
  def change
    create_table :invitations do |t|
      t.string :email, null: false
      t.references :company, null: false, foreign_key: true
      t.string :token, null: false
      t.datetime :invited_at

      t.timestamps
    end
    add_index :invitations, [:email, :company_id], unique: true
  end
end
