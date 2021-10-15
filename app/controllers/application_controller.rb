class ApplicationController < ActionController::Base
  include Pundit

  before_action :authenticate_user!, unless: :auth_request?

  # after_action :verify_authorized, except: :index, unless: :skip_pundit?
  # after_action :verify_policy_scoped, only: :index, unless: :skip_pundit?
  skip_before_action :verify_authenticity_token

  private

  def skip_pundit?
    devise_controller? || params[:controller] =~ /(^(rails_)?admin)|(^pages$)|(^auth$)/
  end

  def auth_request?
    params[:controller].include?("devise_token_auth") &&
      ((controller_name == "sessions" && action_name == "create") ||
      (controller_name == "registrations" && action_name == "create"))
  end

  def dashboard_path_for_user(user)
    case user.access
    when 'user'
      user_dashboard_path
    when 'partner_user'
      partner_user_dashboard_path
    when 'partner_admin'
      partner_admin_dashboard_path
    when 'admin'
      admin_dashboard_path
    else 
      raise
    end
  end

  def after_sign_in_path_for(resource)
    dashboard_path_for_user(resource)
  end

  def after_sign_up_path_for(resource)
    dashboard_path_for_user(resource)
  end
end
