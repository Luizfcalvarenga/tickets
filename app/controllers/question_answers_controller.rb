
class QuestionAnswersController < ApplicationController
  skip_before_action :authenticate_user!, only: [:show, :index]
  
  def new
    @order = Order.find(params[:order_id])
    @order_items = @order.order_items
    @event = @order.event_related_to_order_items
    @question_answer = QuestionAnswer.new
  end

  def create
    raise
  end

  private

  def question_answers_params
    
  end
end
