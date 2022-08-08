class DayUsesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:show, :index]

  def index
    @day_uses = DayUse.all
  end
  
  def show
    @day_use = DayUse.find(params[:id])
    @order = Order.new

    if !current_user
      session[:fall_back_url] = request.url
    end
  end
end
