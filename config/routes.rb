Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }

  devise_scope :user do
    get '/current_user', to: 'users/sessions#show'
  end

  # =====================
  # USERS / AUTH
  # =====================
  resources :users, only: [:index]

  resources :users_connections

  # =====================
  # PALETTES / BUSINESS
  # =====================
  resources :palette_records, only: [:index, :create, :update] do
    collection do
      get :debt
    end
  end

  resources :debts, only: [:index]

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
  resources :company_users, only: [:index, :update, :destroy] do
    post :invite, on: :collection
  end

  # =====================
  # SAAS SUPER ADMIN
  # =====================
  namespace :admin do
    get 'dashboard', to: 'dashboard#index'
    resources :companies, only: [:index, :create, :destroy]
    resources :users, only: [:index, :update, :create]
  end

  post '/signup_from_invite', to: 'users#signup_from_invite'

  get '/invitations/accept/:token', to: 'invitations#accept', as: :accept_invitation

end
