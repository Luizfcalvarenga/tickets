Rails.application.routes.draw do  
  devise_for :users
  root to: 'pages#home'

  # mount ActionCable.server => '/cable'

  get "dashboard", to: "pages#dashboard", as: "dashboard" 
  get "clean", to: "pages#clean", as: "clean" 

  get "user_dashboard", to: "dashboards#user_dashboard", as: "user_dashboard"
  get "partner_user_dashboard", to: "dashboards#partner_user_dashboard", as: "partner_user_dashboard"
  get "partner_admin_dashboard", to: "dashboards#partner_admin_dashboard", as: "partner_admin_dashboard"
  get "admin_dashboard", to: "dashboards#admin_dashboard", as: "admin_dashboard"

  require "sidekiq/web"
  authenticate :user, ->(user) { user.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      mount_devise_token_auth_for 'User', at: 'auth'

      get 'qrcodes/:identifier/show', to: 'qrcodes#show', as: "qrcode_show"
      get 'qrcodes/:identifier/scan', to: 'qrcodes#scan', as: "qrcode_scan"

      get 'users/me', to: 'users#me'
    end
  end
  
  resource :profiles

  namespace :partner_admin do
    resources :events, only: [:show, :new, :create]
    resources :memberships
  end

  resources :partners do
    resources :events, only: [:show]
  end

  namespace :admin do
    resources :partners
    get 'partners/:slug/edit', to: 'partners#edit', as: "partner_slug_edit"
  end

  resources :events, only: [:index, :show] do
    resources :qrcodes, only: [:create]
    resources :event_communications, only: [:index, :show, :new, :create]
  end

  get "events/:id/read", to: "events#read", as: "read_event" 

  resources :user_memberships

  get '/cities_by_state' => 'cities#cities_by_state'

  resources :qrcodes
  get "qrcodes/:id/read", to: "qrcodes#read", as: "read_qrcode"

  get "/:id", to: "partners#show", as: "partner_shortcut"
end
