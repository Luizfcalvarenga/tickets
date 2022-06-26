class EventCloner
  attr_reader :base_event, :event, :params, :current_user, :errors
  def initialize(base_event, current_user)
    @base_event = base_event
    @current_user = current_user
    @errors = {}
  end

  def call
    ActiveRecord::Base.transaction do
      @event = Event.new(event_params)

      if @event.save
        create_batch_params.each_with_index do |batch_params|
          EventBatch.create!(event: @event, 
            pass_type: batch_params[:pass_type],
            name: batch_params[:name],
            quantity: batch_params[:quantity],
            price_in_cents: batch_params[:price_in_cents],
            order: batch_params[:order])
        end
     
        questions_params.each do |question_params|
          question = Question.create!(
            event: @event,
            kind: question_params[:kind],
            prompt: question_params[:prompt],
            optional: question_params[:optional].present?,
            options: question_params[:options],
            order: question_params[:order],
          )
        end

        file = URI.open(@base_event.photo.url)
        @event.photo.attach(io: file, filename: "#{@event.name}_photo.jpg")

        if @base_event.presentation.attached?
          file = URI.open(@base_event.presentation.url)
          @event.presentation.attach(io: file, filename: "#{@event.name}_presentation.jpg")
        end
        
        return true
      else
        @errors[:base] = @event.errors.full_messages
        raise
      end
    end
  rescue
    return false
  end

  # private

  def event_params
    @base_event.attributes.except("id", "created_at", "updated_at", "created_by_id", "absorb_fee", "approved_at", "approved_by_id", "deactivated_at", "description", "terms_of_use", "group_buy_code").symbolize_keys.merge({description: @base_event.description, terms_of_use: @base_event.terms_of_use, created_by: current_user, name: "#{@base_event.name} (Clone)"})
  end

  def create_batch_params
    @base_event.event_batches.map { |event_batch| event_batch.attributes.except("created_at", "updated_at", "id", "event_id").symbolize_keys } || []
  end

  def questions_params
    @base_event.questions.active.map { |question| question.attributes.except("created_at", "updated_at", "id", "ends_at", "event_id", "day_use_id").symbolize_keys } || []
  end
end
