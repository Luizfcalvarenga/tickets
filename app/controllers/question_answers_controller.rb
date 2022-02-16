
class QuestionAnswersController < ApplicationController
  skip_before_action :authenticate_user!, only: [:show, :index]
  
  def new
    @order = Order.find(params[:order_id])
    @order_items = @order.order_items
    @event = @order.event_related_to_order_items
    @question_answer = QuestionAnswer.new
  end

  def create
    @order = Order.find(params[:order_id])
    
    begin
      ActiveRecord::Base.transaction do
        @question_answers = question_answers_params.map do |question_answer_params|
          QuestionAnswer.create!(
            order_item_id: question_answer_params[:order_item_id],
            event_question_id: question_answer_params[:event_question_id],
            value: question_answer_params[:value],
          )
        end

        raise ActiveRecord::RecordInvalid unless @question_answers.all?(&:persisted?)
      end
    rescue ActiveRecord::RecordInvalid => e
      @errors = true
      @order_items = @order.order_items
      @event = @order.event_related_to_order_items
      @question_answer = QuestionAnswer.new
      render :new and return
    end

    redirect_to order_path(@order) and return
  end

  private

  def question_answers_params
    params.permit(event_user_answers: [:order_item_id, :event_question_id, :value])[:event_user_answers]
  end
end
