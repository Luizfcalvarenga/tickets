module Admin
  class OrdersController < ApplicationController
    def index
      @reference_date = params[:date].present? && params[:date][:year].present? && params[:date][:month].present? ? Time.new(params[:date][:year].to_i, params[:date][:month].to_i, 1) : Time.current
      min_date = @reference_date.at_beginning_of_month
      max_date = @reference_date.at_end_of_month.change(hour: 23, min: 59, sec: 59)

      @orders = Order.joins(order_items: :pass).where("(invoice_paid_at > ? and invoice_paid_at < ?) OR (value = 0)", min_date, max_date).distinct(:id).order(:id)
      @passes = Pass.joins(order_item: :order).where(orders: {id: @orders.ids})
      
      @net_total_sales = @orders.map(&:net_value).sum
      @net_result = @net_total_sales - @orders.map(&:amount_to_transfer_to_partner).sum
    end
  end
end
