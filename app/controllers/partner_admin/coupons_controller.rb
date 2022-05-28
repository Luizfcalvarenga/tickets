module PartnerAdmin
  class CouponsController < ApplicationController
    def new
      @coupon = Coupon.new
      @entity = params[:entity_type].constantize.find(params[:entity_id])
    end

    def create
      @coupon = Coupon.new(coupon_params)

      if @coupon.save
        flash[:notice] = "Cupom criado com sucesso"
        redirect_to redirect_route
      else
        flash[:alert] = "Erro ao criar cupom"
        render :new
      end
    end

    def edit
      @coupon = Coupon.find(params[:id])
      @entity = @coupon.entity
    end

    def update
      @coupon = Coupon.find(params[:id])

      if @coupon.update(coupon_params)
        flash[:notice] = "Cupom atualizado com sucesso"
        redirect_to redirect_route
      else
        flash[:alert] = "Erro ao criar cupom"
        render :edit
      end
    end

    def destroy
      @coupon = Coupon.find(params[:id])

      if @coupon.update(coupon_params)
        flash[:notice] = "Cupom desativado com sucesso"
        redirect_to redirect_route
      else
        flash[:alert] = "Erro ao desativar cupom"
      end
    end

    def coupon_params
      params.require(:coupon).permit(:entity_id, :entity_type, :redemption_limit, :valid_until, :code, :kind, :discount)
    end

    def redirect_route
      if @coupon.entity.class == Event
        partner_admin_event_path(@coupon.entity, current_tab: "coupons-tab")
      elsif @coupon.entity.class == DayUse
        partner_admin_day_use_path(@coupon.entity, current_tab: "coupons-tab")
      else
        raise
      end
    end
  end
end
