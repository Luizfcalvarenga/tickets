class ApplicationController < ActionController::Base
  include Pundit

  before_action :authenticate_user!, unless: :auth_request?
  before_action :configure_permitted_parameters, if: :devise_controller?



  # after_action :verify_authorized, except: :index, unless: :skip_pundit?
  # after_action :verify_policy_scoped, only: :index, unless: :skip_pundit?
  skip_before_action :verify_authenticity_token

  private

  def configure_permitted_parameters
    # For additional fields in app/views/devise/registrations/new.html.erb
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :document_number])

    # For additional in app/views/devise/registrations/edit.html.erb
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :document_number])
  end

  def skip_pundit?
    devise_controller? || params[:controller] =~ /(^(rails_)?admin)|(^pages$)|(^auth$)/
  end

  def auth_request?
    params[:controller].include?("devise_token_auth") &&
      ((controller_name == "sessions" && action_name == "create") ||
      (controller_name == "registrations" && action_name == "create"))
  end

  def dashboard_path_for_user(user, **args)
    case user.access
    when 'user'
      user_dashboard_path(**args)
    when 'partner_user'
      partner_user_dashboard_path(**args)
    when 'partner_admin'
      partner_admin_dashboard_path(**args)
    when 'admin'
      admin_dashboard_path(**args)
    else 
      raise
    end
  end
  helper_method :dashboard_path_for_user

  def after_sign_in_path_for(resource)
    url = session[:fall_back_url]
    session[:fall_back_url] = nil
  
    url.presence || dashboard_path_for_user(resource)
  end

  def after_sign_up_path_for(resource)
    url = session[:fall_back_url]
    session[:fall_back_url] = nil
  
    url.presence || dashboard_path_for_user(resource)
  end

  def next_date_for_weekday(weekday_name)
    return Date.today if Time.current.strftime("%A").downcase.to_sym == weekday_name.downcase.to_sym

    Date.today.next_occurring(weekday_name.downcase.to_sym)
  end

  def redirect_to_return_url_if_one_is_provided
    redirect_to params[:return_url] if params[:return_url].present?
  end
end
