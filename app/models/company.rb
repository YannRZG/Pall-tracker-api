class Company < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :invitations
  has_many :palette_records, dependent: :destroy

  validates :name, presence: true
end
