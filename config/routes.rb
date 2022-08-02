Rails.application.routes.draw do  
  devise_for :users, controllers: {
    passwords: 'users/passwords',
    registrations: 'users/registrations',
    sessions: 'users/sessions',
  }
  root to: 'pages#home'

  get "partnership", to: "pages#partnership", as: "partnership"

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

      get 'day_uses/:id', to: 'day_uses#show', as: "day_use"

      get 'passes/:identifier/show', to: 'passes#show', as: "pass_show"
      get 'passes/:identifier/scan', to: 'passes#scan', as: "pass_scan"

      get 'coupons/:coupon_code', to: 'coupons#show', as: "show_coupon"

      get 'users/me', to: 'users#me'
    end
  end
  
  resources :payment_methods
  
  resource :profiles
  
  namespace :partner_admin do
    resources :events
    patch "events/:id/delete_attachments", to: "events#delete_attachments", as: "event_delete_attachments"
    delete "events/:id/delete_group", to: "events#delete_group", as: "delete_group"
    patch "events/:id/toggle_activity", to: "events#toggle_activity", as: "event_toggle_activity"
    post 'events/:id/clone', to: "events#clone", as: "event_clone"
    resources :memberships
    patch "memberships/:id/toggle_activity", to: "memberships#toggle_activity", as: "membership_toggle_activity"
    resources :day_uses do
      resources :day_use_blocks, only: [ :new, :create, :destroy ]
    end
    patch "day_uses/:id/toggle_activity", to: "day_uses#toggle_activity", as: "day_use_toggle_activity"
    resources :partners
    resources :orders
    resources :coupons
  end

  resources :partners do
    resources :events, only: [:show]
  end

  resources :orders do
    resources :question_answers, only: [:show, :new, :create]
  end
  get "orders/:id/status", to: "orders#status", as: "order_status"
  post "orders/:id/pay_with_card", to: "orders#pay_with_card", as: "order_pay_with_card"

  namespace :admin do
    resources :orders
    resources :partners
    resources :users, only: [:index, :new, :create]
    
    get 'partners/:slug/edit', to: 'partners#edit', as: "partner_slug_edit"
    patch 'partners/:slug/toggle_active', to: 'partners#toggle_active', as: "partner_toggle_active"

    get 'approve/:entity_class/:entity_id', to: 'admin#approve_form', as: "approve_form"
    patch 'approve/:entity_class/:entity_id', to: 'admin#approve', as: "approve"
  end

  resources :events, only: [:index, :show] do
    resources :passes, only: [:create]
    resources :event_communications, only: [:index, :show, :new, :create]
  end

  get "day_uses/:id/:date", to: "day_uses#show", as: "day_use"
  get "day_uses", to: "day_uses#index"

  resources :memberships, only: [:show]
  resources :user_memberships
  
  get '/cities_by_state' => 'cities#cities_by_state'
  
  get "passes/scanner", to: "passes#scanner", as: "pass_scanner" 
  resources :passes
  get "passes/:id/read", to: "passes#read", as: "read_pass"
  get 'passes/:identifier/download', to: 'passes#download', as: "pass_download"

  get "/:id", to: "partners#show", as: "partner_shortcut"
end
