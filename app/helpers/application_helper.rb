require Rails.root.join('db/seeds/states_and_cities_populate')
require 'faker'
require 'open-uri'

module ApplicationHelper
  def resource_name
    :user
  end
 
  def resource
    @resource ||= User.new
  end

  def resource_class
    User
  end
 
  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  def mobile_device?
    if session[:mobile_param]
      session[:mobile_param] == "1"
    else
      request.user_agent =~ /Mobile|webOS/
    end
  end

  def display_price(price_in_cents)
    number_to_currency(price_in_cents.to_f/100, unit: "R$", separator: ",", delimiter: ".")
  end

  def cpf_mask(cpf)
    return "-" if cpf.blank?

    cpf.gsub(/[^0-9]/, '').insert(3, ".").insert(7, ".").insert(11, "-")
  end

  def month_number_to_name_abr(month_number)
    {
      "1" => "Jan",
      "2" => "Fev",
      "3" => "Mar",
      "4" => "Abr",
      "5" => "Mai",
      "6" => "Jun",
      "7" => "Jul",
      "8" => "Ago",
      "9" => "Set",
      "10" => "Out",
      "11" => "Nov",
      "12"=> "Dez",
    }[month_number.to_s]
  end

  def weekday_number_to_name_abr(weekday_number)
    {
      "0" => "Dom",
      "1" => "Seg",
      "2" => "Ter",
      "3" => "Qua",
      "4" => "Qui",
      "5" => "Sex",
      "6" => "Sab",
    }[weekday_number.to_s]
  end

  def edit_entity_path(entity)
    case entity.class.name 
    when "Event" 
      edit_partner_admin_event_path(entity)
    when "DayUse" 
      edit_partner_admin_day_use_path(entity)
    when "Membership" 
      edit_partner_admin_membership_path(entity)
    else 
      raise
    end 
  end

  def partner_admin_entity_toggle_activity_path(entity)
    case entity.class.name 
    when "Event" 
      partner_admin_event_toggle_activity_path(entity)
    when "DayUse" 
      partner_admin_day_use_toggle_activity_path(entity)
    when "Membership" 
      partner_admin_membership_toggle_activity_path(entity)
    else 
      raise
    end 
  end

  def day_use_schedule_photo(day_use_schedule)
    day_use_schedule.photo&.key.present? ? day_use_schedule.photo.key : (day_use_schedule.day_use.photo&.key.present? ? day_use_schedule.day_use.photo.key : day_use_schedule.partner.logo.key)
  end
end
