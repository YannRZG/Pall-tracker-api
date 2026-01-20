class CreateSignupRequests < ActiveRecord::Migration[8.0]
  def change
    create_table :signup_requests do |t|
      t.string  :company_name, null: false
      t.string  :admin_email,  null: false
      t.text    :message
      t.integer :status, default: 0, null: false  # 0 = pending
      t.references :role, foreign_key: true

      t.timestamps
    end

    add_index :signup_requests, :admin_email, unique: true
  end
end
