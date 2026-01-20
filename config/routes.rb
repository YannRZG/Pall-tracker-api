Rails.application.routes.draw do
  post "/login", to: "sessions#create"
  delete "/logout", to: "sessions#destroy"
  get "/current_user", to: "sessions#show"

  # =====================
  # PUBLIC SIGNUP REQUESTS
  # =====================
  post "/signup-requests", to: "signup_requests#create"

  get "/invitations/:token", to: "invitations#show"
  post "/signup_from_invite", to: "users#signup_from_invite"

  # =====================
  # USERS / CONNECTIONS
  # =====================
  resources :users, only: [ :index ]

  resources :users_connections, only: [ :index, :create, :update, :destroy ]

  resources :roles, only: [ :index ]

  get "/invitations/accept", to: "invitations#accept", as: "accept_invitation"

  # =====================
  # PALETTES / BUSINESS
  # =====================
  resources :palette_records, only: [ :index, :create, :update ] do
    collection do
      get :debt
    end
  end
  resources :debts, only: [ :index ]

  # =====================
  # COMPANIES
  # =====================
  resources :companies, only: [] do
    collection do
      get :debts
    end
    member do
      get :dashboard
    end
  end

  # =====================
  # PROFILE
  # =====================
  get  "/profile",          to: "profiles#show"
  put  "/profile",          to: "profiles#update"
  put  "/profile/password", to: "profiles#update_password"

  # =====================
  # COMPANY ADMIN
  # =====================
  resources :company_users, only: [ :index, :update, :destroy ] do
    post :invite, on: :collection
  end

  # =====================
  # SAAS SUPER ADMIN
  # =====================
  namespace :admin do
    # Dashboard
    get "dashboard", to: "dashboard#index"

    # Companies & Users
    resources :companies, only: [ :index, :create, :destroy ]
    resources :users, only: [ :index, :update, :create ]

    # Signup Requests Approve / Reject
    resources :signup_requests, only: [] do
      member do
        post :approve
        post :reject
      end
    end
  end
end
