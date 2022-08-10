class DayUsesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:show, :index]

  def index
    @day_uses = DayUse.all
  end
  
  def show
    @day_use = DayUse.find(params[:id])
    @order = Order.new

    session[:restore_order] nil if current_user.present?
  end
end
