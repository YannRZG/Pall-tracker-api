class Company < ApplicationRecord
  belongs_to :role
  has_many :users, dependent: :destroy
  has_many :invitations
  has_many :palette_records, dependent: :destroy

  has_many :requested_connections,
   class_name: "UserConnection",
   foreign_key: :requester_id

  has_many :received_connections,
   class_name: "UserConnection",
   foreign_key: :receiver_id

  scope :approved, -> { where(approved: true) }
  scope :pending, -> { where(approved: false) }

  validates :name, presence: true
end
