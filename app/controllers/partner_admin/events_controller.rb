module PartnerAdmin
  class EventsController < ApplicationController
    def show
      @event = Event.find(params[:id])
      @users = User.select('distinct(users.id), users.email, users.access').joins(qrcodes: :event)
        .joins("left join accesses on accesses.event_id = events.id")
        .where(events: { id: @event.id })
      @qrcodes = @event.qrcodes
      @accesses = @event.accesses

      respond_to do |format|
        format.html
        format.csv { send_data @users.to_csv }
      end
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
            EventBatch.create!(event: event, 
              pass_type: batch_params[:pass_type],
              name: batch_params[:name],
              quantity: batch_params[:quantity],
              price: batch_params[:price_in_cents],
              ends_at: batch_params[:ends_at],
              order: index)
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
    private

    def event_params
      params.require(:event).permit(:name, :description, :photo, :scheduled_start, :scheduled_end, :state_id, :city_id, :street_name, :street_number, :street_complement, :neighborhood)
        .merge(created_by: current_user, partner: current_user.partner)
    end
  
    def create_batch_params
      (params[:batches] || [])
    end
  
    def event_questions_params
      params[:event_questions] || []
    end
  end
end
