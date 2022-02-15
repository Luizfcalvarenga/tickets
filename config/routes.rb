Rails.application.routes.draw do  
  devise_for :users
  root to: 'pages#home'

  # mount ActionCable.server => '/cable'

  get "partnership", to: "pages#partnership", as: "partnership"
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

      get 'passes/:identifier/show', to: 'passes#show', as: "pass_show"
      get 'passes/:identifier/scan', to: 'passes#scan', as: "pass_scan"

      get 'users/me', to: 'users#me'
    end
  end
  
  resource :profiles
  
  namespace :partner_admin do
    resources :events, only: [:show, :new, :create]
    resources :memberships
    resources :day_uses
    resources :partners
    # get 'partners/:slug/edit', to: 'partners#edit', as: "partner_slug_edit"
    # dúvida
  end

  resources :partners do
    resources :events, only: [:show]
  end

  resources :orders do
    resources :question_answers, only: [:new, :create]
  end
  get "orders/:id/pay", to: "orders#pay", as: "order_pay"

  namespace :admin do
    resources :partners
    get 'partners/:slug/edit', to: 'partners#edit', as: "partner_slug_edit"
  end

  resources :events, only: [:index, :show] do
    resources :passes, only: [:create]
    resources :event_communications, only: [:index, :show, :new, :create]
  end
  get "day_uses/:id/:date", to: "day_uses#show", as: "day_use"

  
  resources :user_memberships
  
  get '/cities_by_state' => 'cities#cities_by_state'
  
  get "passes/scanner", to: "passes#scanner", as: "pass_scanner" 
  resources :passes
  get "passes/:id/read", to: "passes#read", as: "read_pass"

  get "/:id", to: "partners#show", as: "partner_shortcut"
end
