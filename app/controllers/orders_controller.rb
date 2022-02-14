
class OrdersController < ApplicationController
  skip_before_action :authenticate_user!, only: [:show, :index]
  
  def create
    order = Order.create(user: current_user, status: "confirmed")

    ActiveRecord::Base.transaction do
      order_items_params.each do |order_item_params|
        order_item_params[:quantity].to_i.times do 
          OrderItem.create(order: order,
            event_batch_id: order_item_params[:event_batch_id],
            day_use_schedule_id: order_item_params[:day_use_schedule_id],
            price_in_cents: order_item_params[:price_in_cents],
            start_time: order_item_params[:start_time],
            end_time: order_item_params[:end_time],
          )
        end
      end
    end

    if order.has_any_event_questions?
      redirect_to new_order_question_answer_path(order_id: order.id)
    else 
      OrderPassesGenerator.new(order).call
      redirect_to dashboard_path_for_user(current_user)
    end
  end

  def pay
    
  end

  private

  def order_items_params
    params.require(:order).permit(order_items: [:event_batch_id, :day_use_schedule_id, :quantity, :price_in_cents, :start_time, :end_time])[:order_items]
  end
end
