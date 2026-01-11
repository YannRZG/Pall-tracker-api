class UsersConnectionsController < ApplicationController
  before_action :authenticate_user!

  def index
    user_company = current_user.company

    # Récupérer toutes les connexions où la company de l'utilisateur est impliquée
    @user_connections = UserConnection.includes(
      shipper: :company,
      carrier: :company,
      recipient: :company
    ).where(
      "shipper_id IN (?) OR carrier_id IN (?) OR recipient_id IN (?)",
      user_company.users.pluck(:id),
      user_company.users.pluck(:id),
      user_company.users.pluck(:id)
    )

    render json: @user_connections.to_json(
      include: {
        shipper: { include: :company },
        carrier: { include: :company },
        recipient: { include: :company }
      }
    )
  end
end
