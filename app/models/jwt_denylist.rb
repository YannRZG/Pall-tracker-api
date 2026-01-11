class JwtDenylist < ApplicationRecord
  include Devise::JWT::RevocationStrategies::Denylist

  self.table_name = 'jwt_denylists'

  validates :jti, presence: true
  validates :exp, presence: true

  def self.revoke_jwt(payload, user)
    where(jti: payload['jti']).first_or_create!(exp: Time.at(payload['exp']))
  end

  
end
