class DayUsesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:show, :index]

  def show
    @day_use = DayUse.find(params[:id])
    @day_use_schedule = @day_use.day_use_schedules.find_by(weekday: params[:weekday])
    @order = Order.new
    
    @day_use_schedule_name = next_date_for_weekday(@day_use_schedule.weekday).strftime("%d/%m/%Y")
  end
end
