class CompanyUsersController < ApplicationController
  before_action :authenticate_user!
  before_action :admin_only!

  # Liste tous les users de la company
  def index
    users = current_user.company.users.active.order(:email)
    render json: users.as_json(only: [ :id, :email, :first_name, :last_name ]).map { |u| u.merge(role: current_user.company.role.name) }
  end

  # Créer une invitation (pas encore de user)
  def invite
    invitation = current_user.company.invitations.find_or_initialize_by(email: params[:email])

    if invitation.save
      UserMailer.invite_email(invitation).deliver_later
      render json: { message: "Invitation envoyée à #{invitation.email}" }, status: :ok
    else
      render json: { errors: invitation.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # Update et destroy pour les users existants (pas les invitations)
  def update
    user = current_user.company.users.active.find(params[:id])
    return render json: { error: "Au moins un admin requis" }, status: :unprocessable_entity if removing_last_admin?(user)

    user.update!(admin: params[:admin]) if params.key?(:admin)
    render json: user
  end

  def destroy
    user = current_user.company.users.find(params[:id])
    return render json: { error: "Impossible de supprimer le dernier admin" }, status: :unprocessable_entity if removing_last_admin?(user)

    user.soft_delete
    head :no_content
  end

  private

  def admin_only!
    render json: { error: "Accès interdit" }, status: :forbidden unless current_user.admin?
  end

  def removing_last_admin?(user)
    user.admin? && current_user.company.users.active.admin.count == 1
  end
end
