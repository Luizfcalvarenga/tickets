module PartnerAdmin
  class EventsController < ApplicationController
    def show
      @event = Event.find(params[:id])
      @passes = @event.passes
        .joins(question_answers: :question)
        .distinct("passes.id")
        # .where(question: { prompt: ["Nome completo"] })
        # .order("question_answers.value")
    
      if params[:query].present?
        sql_query = "question_answers.value ILIKE :query"
        @passes = @passes.where(sql_query, query: "%#{params[:query]}%") if params[:query].present?
      end      

      # @passes = @passes.group("passes.id").order("MAX(question_answers.value) DESC")

      @order = Order.new

      respond_to do |format|
        format.html
        format.csv { send_data @event.passes_csv }
        format.text { render partial: 'partner_admin/events/user_list', locals: { event: @event, passes: @passes }, formats: [:html] }
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

          event.create_default_questions
        
          questions_params.each do |question_params|
            question = Question.create!(
              event: event,
              kind: question_params[:kind],
              prompt: question_params[:prompt],
              optional: question_params[:optional].present?,
              options: question_params[:options],
              order: event.questions.count,
            )
            event.event_batches.each do |event_batch|
              QuestionBatch.create(event_batch: event_batch, question: question)
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
  
    def questions_params
      params[:questions] || []
    end
  end
end
