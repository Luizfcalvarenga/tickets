
class EventsController < ApplicationController

  def show
    @event = Event.find(params[:id])
    @current_batch = @event.current_batch

    @best_membership_with_discount = @event.membership_events
      .where(membership_id: current_user.memberships.where(partner: @event.partner))
        .where("membership_events.discount > ?", 0)
        .order(:discount).last
    @current_price = @best_membership_with_discount.present? && @current_batch.present? ? @current_batch.price * (1 - @best_membership_with_discount.discount) : @current_batch&.price
  
    @qrcode = Qrcode.new
  end

  def new
    @event = Event.new
    @memberships = current_user.partner.memberships
    @states = State.all
    @cities = @event.state.present? ? @event.state.cities : []
  end

  def create
    event = Event.new(event_params)
    
    ActiveRecord::Base.transaction do
      if event.save
        create_batch_params.each_with_index do |batch_params, index|
          Batch.create!(event: event, name: batch_params[:name], quantity: batch_params[:quantity], price: batch_params[:price], order: index)
        end
        
        create_membership_events_params.each do |membership_events_params|
          membership = event.partner.memberships.find(membership_events_params[:id])
          MembershipEvent.create!(
            event: event,
            membership: membership,
            discount: membership_events_params[:discount].to_f/100,
          )
        end

        event_questions_params.each do |event_question_params|
          EventQuestion.create!(
            event: event,
            kind: event_question_params[:kind],
            prompt: event_question_params[:prompt],
            optional: event_question_params[:optional].present?,
            options: event_question_params[:options],
            order: event_question_params[:order],
          )
        end
        
        redirect_to dashboard_path_for_user(current_user)
      else
        raise
        # TODO // add mensagem de erro //
      end
    end
  end

  def read
    @event = Event.find(params[:id])
    @session = Session.create(user: current_user, event: @event)
  end

  private

  def event_params
    params.require(:event).permit(:name, :description, :photo, :scheduled_start, :scheduled_end, :state_id, :city_id, :street_name, :street_number, :street_complement, :neighborhood)
      .merge(created_by: current_user, partner: current_user.partner)
  end

  def create_batch_params
    (params[:batches] || []).select { |batch_params| batch_params[:name].present? || batch_params[:quantity].present? || batch_params[:price].present? } 
  end

  def create_membership_events_params
    params[:memberships] || []
  end

  def event_questions_params
    params[:event_questions] || []
  end
end
