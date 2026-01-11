class User < ApplicationRecord
  before_create :generate_invite_token, if: -> { self.invited_at.nil? }

  scope :active, -> { where(deleted_at: nil) }
  belongs_to :company, optional: true
  enum :role, { shipper: 0, carrier: 1, recipient: 2, admin: 3 }

  validates :role, presence: true
  validate :company_presence_unless_super_admin
  #validates :first_name, presence: true
  #validates :last_name, presence: true
  # -------------------
  # Devise
  # -------------------
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist

  # -------------------
  # Associations
  # -------------------
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


  def super_admin?
    super_admin
  end
        
  def company_admin?
    role == "admin" && !super_admin
  end

  def company_presence_unless_super_admin
    if !super_admin? && company.nil?
      errors.add(:company, "doit être présente pour un utilisateur non super-admin")
    end
  end

  # -------------------
  # Méthode pour récupérer un user depuis un token JWT
  # -------------------
  def self.get_user_from_token(token)
    jwt_payload, = JWT.decode(
      token,
      Rails.application.credentials.devise_jwt_secret_key || ENV['JWT_SECRET_KEY'],
      true,
      algorithm: 'HS256'
    )

    [User.find(jwt_payload['sub']), jwt_payload]
  rescue JWT::DecodeError => e
    Rails.logger.error("JWT invalide : #{e.message}")
    nil
  end

  def soft_delete
    update(deleted_at: Time.current)
  end

  def generate_invite_token
    self.invite_token = SecureRandom.hex(15)
    self.invited_at = Time.current
  end
end
