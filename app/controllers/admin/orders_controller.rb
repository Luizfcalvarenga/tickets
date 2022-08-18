module Admin
  class OrdersController < ApplicationController
    def index
      @reference_date = params[:date].present? && params[:date][:year].present? && params[:date][:month].present? ? Time.new(params[:date][:year].to_i, params[:date][:month].to_i, 1) : Time.current
      min_date = @reference_date.at_beginning_of_month
      max_date = @reference_date.at_end_of_month.change(hour: 23, min: 59, sec: 59)

      @orders = Order.where("invoice_paid_at > ? and invoice_paid_at < ?", min_date, max_date).order(:invoice_paid_at).uniq
      @passes = Pass.joins(order_item: :order).where(orders: {id: @orders.map(&:id)})

      @net_total_sales = @orders.map(&:net_value).compact.sum
      @net_result = @net_total_sales - @orders.map(&:amount_to_transfer_to_partner).sum

      respond_to do |format|
        format.html
        format.csv { send_data Order.where(id: @orders.map(&:id)).to_csv("admin"), filename: "Nuflowpass - Controle financeiro - #{@reference_date.strftime("%B/%Y")}.csv" }
      end
    end

    def destroy
      order = Order.find(params[:id])

      order.order_items.each do |order_item|
        order_item.pass&.accesses&.destroy_all
        order_item.pass&.reads&.destroy_all
        order_item.pass&.destroy!
        order_item.coupon_order_item&.destroy!
        order_item.question_answers.destroy_all
        order_item.destroy!
      end
      order.destroy!

      redirect_to admin_orders_path, notice: "Pedido #{order.id} excluído com sucesso."
    end
  end
end
