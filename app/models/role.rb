class Role < ApplicationRecord
  has_many :user_connections

  validates :name, :code, presence: true
  validates :code, uniqueness: true
end