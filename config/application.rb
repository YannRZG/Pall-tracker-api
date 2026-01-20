require_relative "boot"

require "rails/all"
Bundler.require(*Rails.groups)

module PallTrackerApi
  class Application < Rails::Application
    config.load_defaults 8.0
    config.api_only = true

    # Autoload lib
    config.autoload_lib(ignore: %w[assets tasks])

    # --------------------------
    # CORS pour ton front Vue
    # --------------------------
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins 'http://localhost:5173'
    
        resource '*',
          headers: :any,
          methods: [:get, :post, :put, :patch, :delete, :options],
          credentials: true
      end
    end

    # --------------------------
    # Middleware pour cookies & session (nécessaire pour API + withCredentials)
    # --------------------------
    # Choisis une clé pour la session cookie
    config.session_store :cookie_store, key: "_pall_tracker_session"

    # Ajoute manuellement les middlewares nécessaires
    config.middleware.use ActionDispatch::Cookies
    config.middleware.use ActionDispatch::Session::CookieStore, config.session_options

    # Note : pour JWT, tu peux stocker les tokens côté front, mais le stack middleware Rails doit exister.
  end
end
