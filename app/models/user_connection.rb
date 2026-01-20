class UserConnection < ApplicationRecord
  belongs_to :requester, class_name: "Company"
  belongs_to :receiver,  class_name: "Company"
  belongs_to :role

  enum :status, {
    pending: 0,
    accepted: 1,
    rejected: 2
  }

  validates :role, presence: true
  validates :requester_id, uniqueness: {
    scope: :receiver_id,
    message: "connexion déjà existante"
  }
end
