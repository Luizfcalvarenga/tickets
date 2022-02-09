
class OrdersController < ApplicationController
  skip_before_action :authenticate_user!, only: [:show, :index]
  
  def create
    order = Order.create(user: current_user)

    ActiveRecord::Base.transaction do
      order_items_params.each do |order_item_params|
        order_item_params[:quantity].to_i.times do 
          OrderItem.create(order: order,
            event_batch_id: order_item_params[:event_batch_id],
            day_use_id: order_item_params[:day_use_id],
            price_in_cents: order_item_params[:price_in_cents],
          )
        end
      end
    end

    if order.has_any_event_questions?
      redirect_to new_order_question_answer_path(order_id: order.id)
    else 
      redirect_to root_path
    end
  end

  def pay
    
  end

  private

  def order_items_params
    params.require(:order).permit(order_items: [:event_batch_id, :day_use_id, :quantity, :price_in_cents])[:order_items]
  end
end
