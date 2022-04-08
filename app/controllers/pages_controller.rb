class PagesController < ApplicationController
  include ApplicationHelper
  skip_before_action :authenticate_user!, except: [:dashboard, :clean]

  def home
    @events = Event.active.where("scheduled_end > ?", Time.current).order(:scheduled_start)
  end

  def partnership
  end
end
