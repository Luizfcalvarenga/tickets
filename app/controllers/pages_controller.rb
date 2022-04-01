require 'rake'

Rake::Task.clear # necessary to avoid tasks being loaded several times in dev mode
# Sample::Application.load_tasks # providing your application name is 'sample'

class PagesController < ApplicationController
  include ApplicationHelper
  skip_before_action :authenticate_user!, except: [:dashboard, :clean]

  def home
    @events = Event.active.where("scheduled_start > ?", Time.current + 1.day).order(:scheduled_start).first(4)
  end

  def partnership
  end

  def error_test
    raise "This is a test error for Honeybadger"
  end
end
