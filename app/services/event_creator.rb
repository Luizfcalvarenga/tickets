class EventCreator
  attr_reader :event, :params, :current_user, :errors
  def initialize(params, current_user)
    @params = params
    @current_user = current_user
    @errors = {event: [], event_batches: [], questions: []}
  end

  def call
    @event = Event.new(event_params)
    
    ActiveRecord::Base.transaction do
      event_save_result = @event.save

      create_batch_params.each_with_index do |batch_params, index|
        event_batch = EventBatch.create(event: @event, 
          pass_type: batch_params[:pass_type],
          name: batch_params[:name],
          quantity: batch_params[:quantity],
          price_in_cents: batch_params[:price_in_cents],
          number_of_accesses_granted: batch_params[:number_of_accesses_granted],
          ends_at: batch_params[:ends_at],
          order: batch_params[:order])

        if !event_batch.persisted? 
          errors[:event_batches] << {
            index: batch_params[:form_identifier],
            error: event_batch.errors
          }
        end
      end

      @event.create_default_questions
      
      questions_params.each do |question_params|
        question = Question.create(
          event: @event,
          kind: question_params[:kind],
          prompt: question_params[:prompt],
          optional: question_params[:optional].present?,
          options: question_params[:options] || [],
          order: @event.questions.active.count,
        )
        if !question.persisted? 
          errors[:questions] << {
            index: question_params[:form_identifier],
            error: question.errors
          }
        end
      end
      
      raise if !event_save_result
      raise if errors[:event_batches].present?
      raise if errors[:questions].present?
      
      return true
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
    params.require(:event).permit(event_batches: [:order, :pass_type, :name, :price_in_cents, :number_of_accesses_granted, :quantity, :ends_at, :form_identifier])[:event_batches] || []
  end

  def questions_params
    result = params[:questions] || []
    result.each { |res| res[:options] = res[:options].presence || [] }
    result
  end
end
