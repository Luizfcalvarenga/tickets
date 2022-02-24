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

        if params[:order_item][:event_batch_id].present?
          entity = EventBatch.find(params[:order_item][:event_batch_id])
          start_time = entity.event.scheduled_start
          end_time = entity.event.scheduled_end
        elsif params[:order_item][:day_use_schedule_id].present?
          entity = DayUseSchedule.find(params[:order_item][:day_use_schedule_id])
          start_time = params[:order_item][:start_time].to_datetime
          end_time = params[:order_item][:start_time].to_datetime +  entity.sanitized_slot_duration_in_minutes.minutes
        else
          raise
        end

        order_item = OrderItem.create(order: @order,
          event_batch_id: params[:order_item][:event_batch_id],
          day_use_schedule_id: params[:order_item][:day_use_schedule_id],
          price_in_cents: entity.price_in_cents,
          fee_percentage: entity.partner.fee_percentage,
          total_in_cents: entity.price_in_cents * (1 + entity.partner.fee_percentage / 100),
          start_time: start_time,
          end_time: end_time,
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
      params.require(:user).permit(:email, :name, :document_number)
    end

    def question_answers_params
      params.require(:order).permit(user_answers: [:order_item_id, :question_id, :value])[:user_answers]
    end
  end
end
