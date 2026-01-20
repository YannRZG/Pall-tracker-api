class UsersConnectionsController < ApplicationController
  before_action :authenticate_user!

  def index
    connections = UserConnection
      .includes(:role, :requester, :receiver)
      .where(
        requester: current_user.company
      ).or(
        UserConnection.where(receiver: current_user.company)
      )

    render json: connections.as_json(
      include: {
        role: {},
        requester: { only: [:id, :name] },
        receiver: { only: [:id, :name] }
      }
    )
  end

  def create
    email = params.dig(:users_connection, :email)
    role_code = params.dig(:users_connection, :role)
  
    receiver_company = Company
      .joins(:users)
      .find_by(users: { email: email })
    
    return render json: { error: "Société introuvable" }, status: :not_found unless receiver_company
    return render json: { error: "Impossible d'inviter sa propre société" }, status: :unprocessable_entity if receiver_company == current_user.company
    
    role = Role.find_by(code: role_code)
    return render json: { error: "Rôle invalide" }, status: :unprocessable_entity unless role
  
    connection = UserConnection.new(
      requester: current_user.company,
      receiver: receiver_company,
      role: role,
      status: :pending
    )
  
    if connection.save
      UserConnectionMailer.with(connection: connection).invitation_email.deliver_later
      render json: connection, status: :created
    else
      render json: { errors: connection.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  def update
    connection = UserConnection.find(params[:id])

    return head :forbidden unless connection.receiver == current_user.company
    return render json: { error: "Statut invalide" }, status: :unprocessable_entity unless %w[accepted rejected].include?(params[:status])

    connection.update!(status: params[:status])
    render json: connection
  end

  def destroy
    connection = UserConnection.find(params[:id])

    unless connection.requester == current_user.company || connection.receiver == current_user.company
      return head :forbidden
    end

    connection.destroy!
    head :no_content
  end
end
