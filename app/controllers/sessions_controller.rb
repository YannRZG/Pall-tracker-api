class SessionsController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :create ]

  def create
    user = User.authenticate_by(
      email: session_params[:email],
      password: session_params[:password]
    )

    return render json: { error: "Invalid credentials" }, status: :unauthorized unless user

    reset_session
    session[:user_id] = user.id
    Current.user = user

    render json: {
      user: user.as_json(
        only: [ :id, :email, :role, :company_id ]
      )
    }
  end

  def show
    render json: { user: current_user }
  end

  def destroy
    reset_session
    head :no_content
  end

  private

  def session_params
    params.require(:user).permit(:email, :password)
  end
end
