
class EventsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:show, :index]

  def index
    @events = Event.active
  end
  
  def show
    @event = Event.find(params[:id])
    @current_batches = @event.open_batches
    
    @order = Order.new
    @partner = @event.partner

    if !current_user
      session[:fall_back_url] = request.url
    end
  end

  def read
    @event = Event.find(params[:id])
    @session = Session.create(user: current_user, event: @event)
  end
end
