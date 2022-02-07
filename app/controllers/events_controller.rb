
class EventsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:show, :index]

  def index
    @events = Event.all
  end
  
  def show
    @event = Event.find(params[:id])
    @current_batch = @event.current_batch

    if user_signed_in?
      @best_membership_with_discount = @event.membership_events
        .where(membership_id: current_user.memberships.where(partner: @event.partner))
          .where("membership_events.discount_percentage > ?", 0)
          .order(:discount_percentage).last
    end
    
    @current_price_in_cents = @best_membership_with_discount.present? && @current_batch.present? ? @current_batch.price_in_cents * (1 - @best_membership_with_discount.discount_percentage) : @current_batch&.price_in_cents
    @pass = Pass.new
  end

  def read
    @event = Event.find(params[:id])
    @session = Session.create(user: current_user, event: @event)
  end
end
