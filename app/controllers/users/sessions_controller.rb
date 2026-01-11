class Users::SessionsController < Devise::SessionsController
  respond_to :json
  skip_before_action :verify_signed_out_user, only: [:destroy]

  # Empêche Devise de déclencher les flashs HTML
  def require_no_authentication
    # Ne fait rien, annule le callback
  end

  # POST users/sign_in
  def respond_with(_resource, _opts = {})
    @token = request.env['warden-jwt_auth.token']
    headers['Authorization'] = @token

    render json: {
      status: { code: 200, message: "Connecté avec succès." },
      data: { user: current_user, token: @token }
    }, status: :ok
  end

  # GET /current_user
  def show
    if current_user
      render json: {
        status: { code: 200, message: "Utilisateur connecté" },
        data: {
          user: current_user.as_json(
            only: [:id, :first_name, :last_name, :email, :role, :company_id],
            include: { company: { only: [:id, :name] } }
          )
        }
      }, status: :ok
    else
      render json: {
        status: { code: 401, message: "Utilisateur non trouvé ou non connecté" }
      }, status: :unauthorized
    end
  end
  

  # DELETE users/sign_out
  def respond_to_on_destroy
    token = request.headers['Authorization']&.split(' ')&.last
    user, _payload = User.get_user_from_token(token) if token
  
    if user
      render json: {
        status: { code: 200, message: "Déconnexion réussie." },
        data: { user: user }
      }, status: :ok
    else
      render json: {
        status: { code: 401, message: "L'utilisateur n'a aucune session active." }
      }, status: :unauthorized
    end
  end
  

  private

  def set_user
    @token = request.headers['Authorization'].split(' ').last
    User.get_user_from_token(@token)
  end

  def set_flash_message!(*)
    # Désactivation des flash messages
  end
end
