
class QuestionAnswersController < ApplicationController
  skip_before_action :authenticate_user!, only: [:show, :index]

  def new
    @order = Order.find(params[:order_id])
    @order_items = @order.order_items
    @question_answer = QuestionAnswer.new
    @user = current_user
  end

  def create
    @order = Order.find(params[:order_id])
    @order_items = @order.order_items

    begin
      ActiveRecord::Base.transaction do
        @order_items.each { |order_item| order_item.question_answers.each(&:destroy) }

        @question_answers = question_answers_params.map do |question_answer_params|
          QuestionAnswer.create(
            order_item_id: question_answer_params[:order_item_id],
            question_id: question_answer_params[:question_id],
            value: question_answer_params[:value],
          )
        end

        raise ActiveRecord::RecordInvalid unless @question_answers.all?(&:persisted?)

        if @order.is_free?
          @order.perform_after_payment_confirmation_actions
          flash[:notice] = "Passes retirados com sucesso"
          redirect_to dashboard_path_for_user(current_user) and return
        end
      end
    rescue ActiveRecord::RecordInvalid => e
      @errors = true
      @order_items = @order.order_items
      @question_answer = QuestionAnswer.new
      render :new and return
    end

    redirect_to order_path(@order) and return
  end

  private

  def question_answers_params
    params.permit(user_answers: [:order_item_id, :question_id, :value])[:user_answers]
  end
end
