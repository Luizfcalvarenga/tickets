require 'rake'

Rake::Task.clear # necessary to avoid tasks being loaded several times in dev mode
# Sample::Application.load_tasks # providing your application name is 'sample'

class PagesController < ApplicationController
  include ApplicationHelper
  skip_before_action :authenticate_user!, except: [:dashboard, :clean]

  def home
    @events = Event.all.sample(4)
    
    qrcode = RQRCode::QRCode.new("https://www.lunacali.com")

    @svg = qrcode.as_svg(
      color: "000",
      shape_rendering: "crispEdges",
      module_size: 11,
      standalone: true,
      use_path: true
    )
  end

  def partnership
  end

  def clean
    Pass.destroy_all
    Read.destroy_all
    DayUseSchedulePassType.destroy_all
    DayUseSchedule.destroy_all
    EventBatchQuestion.destroy_all
    Question.destroy_all
    DayUse.destroy_all
    Event.destroy_all
    Membership.destroy_all
    Partner.destroy_all
    Order.destroy_all
    User.destroy_all

    redirect_to dashboard_path_for_user(current_user)
  end

  def seed1
    seed_db_1_event
    redirect_to root_path
    flash[:notice] = 'Seed feito com 1 evento!'
  end

  def seed10
    seed_db_10_events
    redirect_to root_path
    flash[:notice] = 'Seed feito com 10 eventos!'
  end
end
