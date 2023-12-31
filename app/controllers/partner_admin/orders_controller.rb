module PartnerAdmin
  class OrdersController < ApplicationController
    def index
      @reference_date = params[:date].present? && params[:date][:year].present? && params[:date][:month].present? ? Time.new(params[:date][:year].to_i, params[:date][:month].to_i, 1) : Time.current
      min_date = @reference_date.at_beginning_of_month
      max_date = @reference_date.at_end_of_month.change(hour: 23, min: 59, sec: 59)
      partner = current_user.partner

      @orders = Order.joins(:order_items).where(order_items: {partner: partner}).where("invoice_paid_at > ? and invoice_paid_at < ?", min_date, max_date).order(:invoice_paid_at).uniq
      @passes = Pass.joins(order_item: :order).where(orders: {id: @orders.map(&:id)})

      @total_sales = @orders.map(&:total_in_cents).sum
      @amount_to_receive = @orders.map(&:amount_to_transfer_to_partner).sum

      respond_to do |format|
        format.html
        format.csv { send_data Order.where(id: @orders.map(&:id)).to_csv, filename: "Nuflowpass - Controle financeiro - #{@reference_date.strftime("%B/%Y")}.csv" }
      end
    end

    def create
      @user = User.find_by(email: user_params[:email])

      begin
        ActiveRecord::Base.transaction do
          if @user.blank?
            @user = User.create!(user_params.merge(password: "89h23f8932hf892389fh"))
          else
            @user.update!(user_params)
          end

          @order = Order.create(user: @user, directly_generated_by: current_user, free: true, invoice_paid_at: Time.current, value: 0, net_value: 0)

          raise "Nenhum item foi selecionado" if params[:order_item].blank?

          if params[:order_item][:event_batch_id].present?
            entity = EventBatch.find(params[:order_item][:event_batch_id])
            start_time = entity.event.scheduled_start
            end_time = entity.event.scheduled_end
          elsif params[:order_item][:day_use_schedule_pass_type_id].present?
            entity = DayUseSchedulePassType.find(params[:order_item][:day_use_schedule_pass_type_id])
            start_time = params[:order_item][:start_time].to_datetime
            end_time = params[:order_item][:start_time].to_datetime +  entity.day_use_schedule.sanitized_slot_duration_in_minutes.minutes
          else
            raise
          end

          order_item = OrderItem.create(order: @order,
            event_batch_id: params[:order_item][:event_batch_id],
            day_use_schedule_pass_type_id: params[:order_item][:day_use_schedule_pass_type_id],
            price_in_cents: entity.price_in_cents,
            fee_percentage: entity.fee_percentage,
            partner: entity.partner,
            absorb_fee: entity.absorb_fee,
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
        end
      rescue StandardError => e
        flash[:alert] = "Erro ao gerar passe: #{e}"
        redirect_to request.referrer and return
      end

      @order.perform_after_payment_confirmation_actions

      flash[:notice] = "Passe gerado com sucesso"
      redirect_to request.referrer
    end

    private

    def user_params
      params.require(:user).permit(:email, :name, :document_number, :cep, :phone_number)
    end

    def question_answers_params
      params.require(:order).permit(user_answers: [:order_item_id, :question_id, :value])[:user_answers]
    end
  end
end
