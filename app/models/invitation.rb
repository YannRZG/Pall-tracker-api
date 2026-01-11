class Invitation < ApplicationRecord
  belongs_to :company

  before_create :generate_token, :set_invited_at

  validates :email, presence: true, uniqueness: { scope: :company_id }

  private

  def generate_token
    self.token = SecureRandom.hex(20)
  end

  def set_invited_at
    self.invited_at = Time.current
  end
end
