
class EventsController < ApplicationController
  skip_before_action :authenticate_user!, only: :show

  def index
    @events = Event.all
  end
  
  def show
    @event = Event.find(params[:id])
    @current_batch = @event.current_batch

    if user_signed_in?
      @best_membership_with_discount = @event.membership_events
        .where(membership_id: current_user.memberships.where(partner: @event.partner))
          .where("membership_events.discount > ?", 0)
          .order(:discount).last
    end
    
    @current_price = @best_membership_with_discount.present? && @current_batch.present? ? @current_batch.price * (1 - @best_membership_with_discount.discount) : @current_batch&.price
    @qrcode = Qrcode.new
  end

  def read
    @event = Event.find(params[:id])
    @session = Session.create(user: current_user, event: @event)
  end
end
