class SignupRequest < ApplicationRecord
  belongs_to :role
  # Déclare le status comme enum
  enum :status, { pending: 0, approved: 1, rejected: 2 }

  validates :company_name, :admin_email, presence: true
  validates :admin_email, format: { with: URI::MailTo::EMAIL_REGEXP }

  # scopes explicites pour simplifier les queries
  scope :pending_requests, -> { pending.order(created_at: :desc) }
  scope :approved_requests, -> { approved.order(created_at: :desc) }
  scope :rejected_requests, -> { rejected.order(created_at: :desc) }
end
