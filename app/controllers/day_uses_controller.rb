class DayUsesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:show, :index]

  def show
    @day_use = DayUse.find(params[:id])
    @date = params[:date].to_datetime
    @day_use_schedule = @day_use.day_use_schedules.find_by(weekday: @date.strftime("%A").downcase)
    @order = Order.new
  end
end
