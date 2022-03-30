class EventUpdater
  attr_reader :event, :params
  def initialize(event, params)
    @event = event
    @params = params
  end

  def call
    ActiveRecord::Base.transaction do
      if @event.update(event_params)
        update_batches 
        update_questions
        
        return true
      # else
        # raise
      end
    end
  # rescue
    # return false
  end

  def update_batches
    removed_event_batches.destroy_all

    event_batches_to_update.each do |batch_params|
      event_batch = EventBatch.find(batch_params[:id])
      
      update_batch_result = event_batch.update(
        pass_type: batch_params[:pass_type],
        name: batch_params[:name],
        quantity: batch_params[:quantity],
        price_in_cents: batch_params[:price_in_cents],
        ends_at: batch_params[:ends_at],
        order: batch_params[:order]
      )

      if !update_batch_result 
        errors << {order: batch_params[:order], error: event_batch.errors.full_messages.join(", ")}
      end
    end

    new_event_batches.each do |batch_params|
      EventBatch.create!(event: @event, 
        pass_type: batch_params[:pass_type],
        name: batch_params[:name],
        quantity: batch_params[:quantity],
        price_in_cents: batch_params[:price_in_cents],
        ends_at: batch_params[:ends_at],
        order: batch_params[:order])
    end
  end

  def update_questions
    removed_questions.destroy_all

    questions_to_update.each do |question_params|
      question = Question.find(question_params[:id])
      
      update_question = question.update(
        event: @event,
        kind: question_params[:kind],
        prompt: question_params[:prompt],
        optional: question_params[:optional].present?,
        options: question_params[:options],
        order: @event.questions.count,
      )

      if !update_question 
        errors << {order: @event.questions.count, error: question.errors.full_messages.join(", ")}
      end
    end

    new_questions.each do |question_params|
      question = Question.create!(
        event: @event,
        kind: question_params[:kind],
        prompt: question_params[:prompt],
        optional: question_params[:optional].present?,
        options: question_params[:options],
        order: question_params[:order],
      )
    end
  end

  def removed_event_batches
    event.event_batches.where.not(id: received_event_batches_ids)
  end

  def event_batches_to_update
    create_batch_params.select{ |eb| eb[:id].present? }
  end

  def new_event_batches
    create_batch_params.select{ |eb| eb[:id].blank? }
  end

  def received_event_batches_ids
    create_batch_params.sort_by { |eb| eb.is_a?(EventBatch) ? eb.order : eb[:order] }.map{ |eb| eb[:id]}.compact
  end

  def removed_questions
    event.questions.non_default.where.not(id: received_questions_ids)
  end

  def questions_to_update
    questions_params.select{ |q| q[:id].present? }
  end

  def new_questions
    questions_params.select{ |q| q[:id].blank? }
  end

  def received_questions_ids
    questions_params.sort_by { |q| q.is_a?(EventBatch) ? q.order : q[:order] }.map{ |q| q[:id]}.compact
  end

  private

  def event_params
    params.require(:event).permit(:name, :description, :photo, :terms_of_use, :scheduled_start, :scheduled_end, :state_id, :city_id, :street_name, :street_number, :street_complement, :neighborhood, :cep, :address_complement)
  end

  def create_batch_params
    params.require(:event).permit(event_batches: [:id, :order, :pass_type, :name, :price_in_cents, :quantity, :ends_at])[:event_batches]
  end

  def questions_params
    params[:questions] || []
  end
end
