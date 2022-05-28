module Api
  module V1
    class CouponsController < ApplicationController
      skip_before_action :authenticate_user!
      
      def show
        render json: {error: "Entidade não encontrada"} and return if params[:entity_id].blank? || params[:entity_type].blank?

        @entity = params[:entity_type].classify.constantize.find(params[:entity_id])

        render json: CouponChecker.new(params[:coupon_code], @entity).call
      end
    end
  end
end
