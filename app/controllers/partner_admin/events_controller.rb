module PartnerAdmin
  class EventsController < ApplicationController
    def show
      @event = Event.find(params[:id])
      @passes = @event.passes

      respond_to do |format|
        format.html
        format.csv { send_data @event.passes_csv }
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
              price_in_cents: batch_params[:price_in_cents],
              ends_at: batch_params[:ends_at],
              order: batch_params[:order])
          end
        
          event_questions_params.each do |event_question_params|
            event_question = EventQuestion.create!(
              event: event,
              kind: event_question_params[:kind],
              prompt: event_question_params[:prompt],
              optional: event_question_params[:optional].present?,
              options: event_question_params[:options],
              order: event_question_params[:order],
            )
            event.event_batches.each do |event_batch|
              EventQuestionBatch.create(event_batch: event_batch, event_question: event_question)
            end
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
      params.require(:event).permit(:name, :description, :photo, :scheduled_start, :scheduled_end, :state_id, :city_id, :street_name, :street_number, :street_complement, :neighborhood, :cep, :address_complement)
        .merge(created_by: current_user, partner: current_user.partner)
    end
  
    def create_batch_params
      params.require(:event).permit(event_batches: [:order, :pass_type, :name, :price_in_cents, :quantity, :ends_at])[:event_batches]
    end
  
    def event_questions_params
      params[:event_questions] || []
    end
  end
end
