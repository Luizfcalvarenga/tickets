module Admin
  class OrdersController < ApplicationController
    def index
      @reference_date = params[:date].present? && params[:date][:year].present? && params[:date][:month].present? ? Date.new(params[:date][:year].to_i, params[:date][:month].to_i, 1) : Time.current
      min_date = @reference_date.at_beginning_of_month
      max_date = @reference_date.at_end_of_month

      @passes = Pass.from_event_or_day_use.not_free.where("created_at > ? and created_at < ?", min_date, max_date).order(created_at: :desc)
      @total_sales = @passes.sum(:price_in_cents)
      @tax_amount = @total_sales - @passes.map(&:amount_to_transfer_to_partner).sum
    end
  end
end
