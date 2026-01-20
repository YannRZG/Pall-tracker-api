class UsersController < ApplicationController
  respond_to :json
  skip_before_action :authenticate_user!, only: [ :signup_from_invite ]

  def index
    @users = User.all
  end

  def check_admin
    render json: {
      admin: current_user&.admin?,
      super_admin: current_user&.super_admin?
    }
  end


  def signup_from_invite
    invitation = Invitation.find_by(token: params[:token])
    return render json: { error: "Invitation invalide" }, status: :unprocessable_entity unless invitation

    user = User.new(
      user_params.merge(
        email: invitation.email,
        company: invitation.company
      )
    )

    if user.save
      invitation.destroy

      reset_session
      session[:user_id] = user.id
      Current.user = user

      render json: {
        user: user.as_json(
          only: [ :id, :email, :first_name, :last_name, :phone, :role, :company_id ]
        )
      }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :first_name, :last_name, :phone, :password, :password_confirmation)
  end
end
