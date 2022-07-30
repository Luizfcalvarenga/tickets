class EventCreator
  attr_reader :event, :params, :current_user, :errors
  def initialize(params, current_user)
    @params = params
    @current_user = current_user
    @errors = {event_batches: [], questions: []}
  end

  def call
    @event = Event.new(event_params)
    
    ActiveRecord::Base.transaction do
      if @event.save
        create_batch_params.each_with_index do |batch_params, index|
          event_batch = EventBatch.create(event: @event, 
            pass_type: batch_params[:pass_type],
            name: batch_params[:name],
            quantity: batch_params[:quantity],
            price_in_cents: batch_params[:price_in_cents],
            number_of_accesses_granted: batch_params[:number_of_accesses_granted],
            ends_at: batch_params[:ends_at],
            order: batch_params[:order])
        end

        if !event_batch.persisted? 
          errors[:event_batches] << event_batch.errors.full_messages.join(", ")
          raise
        end

        @event.create_default_questions
      
        questions_params.each do |question_params|
          question = Question.create(
            event: @event,
            kind: question_params[:kind],
            prompt: question_params[:prompt],
            optional: question_params[:optional].present?,
            options: question_params[:options],
            order: @event.questions.active.count,
          )
        end

        if !question.persisted? 
          errors[:questions] << question.errors.full_messages.join(", ")
          raise
        end
        
        return true
      else
        raise
      end
    end
  rescue
    return false
  end

  private

  def event_params
    params.require(:event).permit(:name, :description, :experience, :photo, :presentation, :terms_of_use, :scheduled_start, :scheduled_end, :state_id, :city_id, :street_name, :street_number, :street_complement, :neighborhood, :cep, :address_complement, sponsors_photos: [], supporters_photos: [])
      .merge(created_by: current_user, partner: current_user.partner, group_buy: params[:event][:group_buy].to_i == 1)
  end

  def create_batch_params
    params.require(:event).permit(event_batches: [:order, :pass_type, :name, :price_in_cents, :number_of_accesses_granted, :quantity, :ends_at])[:event_batches] || []
  end

  def questions_params
    params[:questions] || []
  end
end
