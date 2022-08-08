module Api
  module V1
    class CouponsController < ApplicationController
      skip_before_action :authenticate_user!
      
      def show
        @entity = params[:entity_type].classify.constantize.find_by(id: params[:entity_id])

        render json: {error: "Entidade não encontrada"} and return if @entity.blank?

        render json: CouponChecker.new(params[:coupon_code], @entity).call
      end
    end
  end
end
