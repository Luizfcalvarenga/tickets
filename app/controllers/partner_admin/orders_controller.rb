module PartnerAdmin
  class OrdersController < ApplicationController
    def create
      @user = User.find_by(email: user_params[:email])

      begin
        if @user.blank?
          @user = User.create!(user_params.merge(password: SecureRandom.uuid))
        else
          @user.update!(user_params)
        end

        @order = Order.create(user: @user, directly_generated_by: current_user)

        entity = if params[:order_item][:event_batch_id].present?
          EventBatch.find(params[:order_item][:event_batch_id])
        elsif params[:order_item][:day_use_schedule_id].present?
          DayUseSchedule.find(params[:order_item][:day_use_schedule_id])
        else
          raise
        end

        order_item = OrderItem.create(order: @order,
          event_batch_id: params[:order_item][:event_batch_id],
          day_use_schedule_id: params[:order_item][:day_use_schedule_id],
          price_in_cents: entity.price_in_cents,
          fee_percentage: entity.partner.fee_percentage,
          total_in_cents: entity.price_in_cents * (1 + entity.partner.fee_percentage / 100),
          start_time: entity.send(:start_time, params[:order_item][:start_time]),
          end_time: entity.send(:end_time, params[:order_item][:end_time]),
        )

        @question_answers = question_answers_params.map do |question_answer_params|
          QuestionAnswer.create(
            order_item_id: order_item.id,
            question_id: question_answer_params[:question_id],
            value: question_answer_params[:value],
          )
        end

        raise ActiveRecord::RecordInvalid unless @question_answers.all?(&:persisted?)
      rescue ActiveRecord::RecordInvalid => e
        flash[:alert] = "Erro ao gerar passe. Preencha todas as informações corretamente"
        redirect_to request.referrer and return
      rescue NovaIugu::CustomerCreator::CustomerParamsException => e
        flash[:alert] = "Erro ao gerar passe. Faltou preencher o nome e/ou documento do usuário."
        redirect_to request.referrer and return
      end

      @order.perform_after_payment_confirmation_actions

      flash[:notice] = "Passe gerado com sucesso"
      redirect_to request.referrer
    end

    private

    def user_params
      params.require(:order).permit(user_attributes: [:email, :name, :document_number])[:user_attributes]
    end

    def question_answers_params
      params.permit(event_user_answers: [:order_item_id, :question_id, :value])[:event_user_answers]
    end
  end

end
