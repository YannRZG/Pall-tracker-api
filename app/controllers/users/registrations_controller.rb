# app/controllers/users/registrations_controller.rb
class Users::RegistrationsController < Devise::RegistrationsController
  respond_to :json

  # Avant création, autoriser les champs personnalisés
  before_action :configure_permitted_parameters, only: [:create]

  # Empêche Devise de déclencher les flashs HTML
  def require_no_authentication
    # Ne fait rien, annule le callback
  end

  # -------------------
  # Création d’un utilisateur
  # -------------------
  def create
    super
  end

  private

  # Autoriser les champs personnalisés pour l’inscription
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:role, :first_name, :last_name])
  end

  # Réponse JSON après création
  def respond_with(resource, _opts = {})
    if resource.persisted?
      render json: { 
        message: 'Inscription réussie', 
        user: resource.as_json(only: [:id, :email, :role, :first_name, :last_name]),
        token: current_token 
      }, status: :ok
    else
      render json: { 
        message: 'Erreur lors de l’inscription', 
        errors: resource.errors.full_messages 
      }, status: :unprocessable_entity
    end
  end

  # Récupérer le token JWT généré par Devise
  def current_token
    request.env['warden-jwt_auth.token']
  end

  # Désactiver les flash messages
  def set_flash_message!(*)
    # Ne rien faire
  end
end
