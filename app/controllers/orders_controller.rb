
class OrdersController < ApplicationController
  skip_before_action :authenticate_user!, only: [:show, :index]

  def show
    @order = Order.find(params[:id])
  end
  
  def create
    @order = Order.create(user: current_user)

    ActiveRecord::Base.transaction do
      order_items_params.each do |order_item_params|
        order_item_params[:quantity].to_i.times do 
          OrderItem.create(order: @order,
            event_batch_id: order_item_params[:event_batch_id],
            day_use_schedule_id: order_item_params[:day_use_schedule_id],
            price_in_cents: order_item_params[:price_in_cents],
            start_time: order_item_params[:start_time],
            end_time: order_item_params[:end_time],
          )
        end
      end
    end

    if @order.free?
      @order.nova_iugu_after_payment_confirmation
      redirect_order_create_and_return
    end

    if @order.invoice_id.blank? || @order.invoice_status == "expired" || @order.invoice_status == "canceled"
      ::NovaIugu::InvoiceGenerator.new(@order, ["pix", "credit_card"]).call
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

    redirect_order_create_and_return
  end

  def status
    @order = Order.find(params[:id])

    ::NovaIugu::ChargeCheckAndUpdateStatus.new(@order).call

    render json: @order.status
  end

  def redirect_order_create_and_return
    if @order.has_any_event_questions?
      redirect_to new_order_question_answer_path(order_id: @order.id) and return
    else 
      redirect_to order_path(@order) and return
    end
  end

  private

  def order_items_params
    params.require(:order).permit(order_items: [:event_batch_id, :day_use_schedule_id, :quantity, :price_in_cents, :start_time, :end_time])[:order_items]
  end
end
