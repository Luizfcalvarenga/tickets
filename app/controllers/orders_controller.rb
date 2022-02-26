
class OrdersController < ApplicationController
  skip_before_action :authenticate_user!, only: [:show, :index]

  def show
    @order = Order.find(params[:id])
    
    if @order.invoice_id.blank? || @order.invoice_status == "expired" || @order.invoice_status == "canceled"
      ::NovaIugu::InvoiceGenerator.new(@order).call
    else
      begin
        ::NovaIugu::ChargeCheckAndUpdateStatus.new(@order).call
      rescue Iugu::ObjectNotFound
        begin
          ::NovaIugu::InvoiceGenerator.new(@order).call
        rescue 
          raise
        end
      end
    end
  end
  
  def create
    @order = Order.create(user: current_user)

    ActiveRecord::Base.transaction do
      order_items_params.each do |order_item_params|
        if order_item_params[:event_batch_id].present?
          entity = EventBatch.find(order_item_params[:event_batch_id])
          start_time = entity.event.scheduled_start
          end_time = entity.event.scheduled_end
        elsif order_item_params[:day_use_schedule_pass_type_id].present?
          entity = DayUseSchedulePassType.find(order_item_params[:day_use_schedule_pass_type_id])
          start_time = order_item_params[:start_time].to_datetime
          end_time = order_item_params[:start_time].to_datetime +  entity.day_use_schedule.sanitized_slot_duration_in_minutes.minute
        else
          raise
        end

        order_item_params[:quantity].to_i.times do 
          OrderItem.create(order: @order,
            event_batch_id: order_item_params[:event_batch_id],
            day_use_schedule_pass_type_id: order_item_params[:day_use_schedule_pass_type_id],
            price_in_cents: entity.price_in_cents,
            fee_percentage: entity.partner.fee_percentage,
            total_in_cents: entity.price_in_cents * (1 + entity.partner.fee_percentage / 100),
            start_time: start_time,
            end_time: end_time,
          )
        end
      end
    end

    if @order.free?
      @order.nova_iugu_after_payment_confirmation
      redirect_to new_order_question_answer_path(order_id: @order.id) and return
    end

    if @order.invoice_id.blank? || @order.invoice_status == "expired" || @order.invoice_status == "canceled"
      ::NovaIugu::InvoiceGenerator.new(@order).call
    else
      begin
        ::NovaIugu::ChargeCheckAndUpdateStatus.new(@order).call
      rescue Iugu::ObjectNotFound
        begin
          ::NovaIugu::InvoiceGenerator.new(@order).call
        rescue 
          raise
        end
      end
    end

    redirect_to new_order_question_answer_path(order_id: @order.id) and return
  end

  def status
    @order = Order.find(params[:id])

    ::NovaIugu::ChargeCheckAndUpdateStatus.new(@order).call

    render json: @order.status
  end

  private

  def order_items_params
    params.require(:order).permit(order_items: [:event_batch_id, :day_use_schedule_pass_type_id, :quantity, :price_in_cents, :start_time, :end_time])[:order_items]
  end
end
