class CouponChecker
  attr_reader :coupon_code, :entity

  def initialize(coupon_code, entity)
    @coupon_code = coupon_code
    @entity = entity
  end
  
  def call
    @coupon = Coupon.active.find_by(entity_id: entity.id, entity_type: entity.class.name, code: coupon_code)

    if @coupon.blank? || @coupon.kind.blank? || @coupon.discount.blank?
      return {
        success: false,
        message: "Cupom não encontrado ou desativado"
      }
    elsif @coupon.limit_reached?
      return {
        success: false,
        message: "Limite de aplicações do cupom foi ultrapassado"
      }
    elsif @coupon.expired?
      return {
        success: false,
        message: "Cupom expirado"
      }
    else
      return {
        success: true,
        message: "Cupom aplicado com sucesso",
        discount_display: @coupon.discount_display,
        coupon: @coupon,
      }
    end
  end
end
