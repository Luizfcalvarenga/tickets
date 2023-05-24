class PagesController < ApplicationController
  include ApplicationHelper
  skip_before_action :authenticate_user!, except: [:dashboard, :clean]

  def home
    @events = Event.active.not_hidden.where("scheduled_end > ?", Time.current).order(:scheduled_start)
  end

  def partnership
  end

  def terms_and_conditions
  end
  
  def privacy_policy
  end
end
