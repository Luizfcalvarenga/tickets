
class EventsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:show, :index]

  def index
    @events = Event.active.where("scheduled_end > ?", Time.current).order(:scheduled_start)
    @past_events = Event.active.where("scheduled_end < ?", Time.current).order(:scheduled_start)
  end
  
  def show
    @event = Event.find(params[:id])

    # if !@event.active?
      # flash[:alert] = "Evento não encontrado ou está com as vendas suspensas"
      # redirect_to root_path
    # end

    @current_batches = @event.open_batches
    @order = Order.new
    @partner = @event.partner

    @events_with_same_experience = @event.partner.events.where(experience: @event.experience).order(:scheduled_start).where("events.scheduled_start > ?", Time.current.at_beginning_of_day).select { |event| event.experience.present? }

    # session[:restore_order] = nil if current_user.present?
    if !current_user
      session[:fall_back_url] = request.url
    end
  end

  def read
    @event = Event.find(params[:id])
    @session = Session.create(user: current_user, event: @event)
  end
end
