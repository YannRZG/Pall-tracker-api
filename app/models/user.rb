class User < ApplicationRecord
  has_secure_password

  before_create :generate_invite_token, if: -> { invited_at.nil? }

  belongs_to :company, optional: true

  scope :active, -> { where(deleted_at: nil) }

  #enum :function, { shipper: 0, carrier: 1, recipient: 2, admin: 3 }
  #enum :function, { user: 0, super_admin: 1 }

  validates :password, length: { minimum: 6 }, if: -> { new_record? || !password.nil? }
  validate :company_presence_unless_super_admin

  has_many :palette_records, dependent: :destroy

  has_many :shipper_connections,
           class_name: "UserConnection",
           foreign_key: :shipper_id

  has_many :carrier_connections,
           class_name: "UserConnection",
           foreign_key: :carrier_id

  has_many :recipient_connections,
           class_name: "UserConnection",
           foreign_key: :recipient_id

  def company_admin?
    admin? && !super_admin?
  end

  def company_presence_unless_super_admin
    return if super_admin?
    errors.add(:company, "doit être présente") if company.nil?
  end

  def soft_delete
    update(deleted_at: Time.current)
  end

  private

  def generate_invite_token
    self.invite_token = SecureRandom.hex(15)
    self.invited_at = Time.current
  end
end
