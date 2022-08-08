class OrderProcessor
  attr_reader :order, :order_items_params, :coupon_code, :errors
  
  def initialize(order, order_items_params, coupon_code)
    @order = order
    @order_items_params = order_items_params
    @coupon_code = coupon_code
  end
  
  def call
    order_item = nil

    ActiveRecord::Base.transaction do
      order_items_params.each do |order_item_params|
        if order_item_params[:event_batch_id].present?
          entity = EventBatch.find(order_item_params[:event_batch_id])
          start_time = entity.event.scheduled_start
          end_time = entity.event.scheduled_end
        elsif order_item_params[:day_use_schedule_pass_type_id].present?
          entity = DayUseSchedulePassType.find(order_item_params[:day_use_schedule_pass_type_id])
          start_time = order_item_params[:start_time].to_datetime
          end_time = order_item_params[:start_time].to_datetime +  entity.day_use_schedule.sanitized_slot_duration_in_minutes.minute
        else
          raise
        end

        order_item_params[:quantity].to_i.times do 
          order_item = OrderItem.create(order: @order,
            event_batch_id: order_item_params[:event_batch_id],
            day_use_schedule_pass_type_id: order_item_params[:day_use_schedule_pass_type_id],
            price_in_cents: entity.price_in_cents,
            fee_percentage: entity.fee_percentage,
            partner: entity.partner,
            absorb_fee: entity.absorb_fee,
            start_time: start_time,
            end_time: end_time,
          )
        end
      end
    end

    related_entity = order_item.related_entity
      
    applicable_coupon = Coupon.active.find_by(entity_id: related_entity.id, entity_type: related_entity.class.name, code: coupon_code)
    if applicable_coupon.present? && applicable_coupon.can_be_applied?
      @order.update!(coupon: applicable_coupon) 
      @order.order_items.each { |order_item| CouponOrderItem.create(order_item: order_item, coupon: applicable_coupon) }
    elsif related_entity.class == DayUse && related_entity.day_use_packages.present?
      day_use_package = related_entity.day_use_packages.first
      appliable_items = order.order_items.where(day_use_schedule_pass_type_id: day_use_package.day_use_schedule_pass_type_ids).sort_by { |item| -item.price_in_cents }
      count_of_passes_to_apply = (appliable_items.count / day_use_package.quantity_of_passes).floor *
        day_use_package.quantity_of_passes;

      if count_of_passes_to_apply > 0
        custom_coupon = Coupon.create(
          day_use_package: day_use_package,
          redemption_limit: 999,
          valid_until: Time.current - 1.day,
          code: SecureRandom.uuid,
          kind: day_use_package.kind,
          discount: day_use_package.discount)
        appliable_items.first(count_of_passes_to_apply).each do |order_item|
          CouponOrderItem.create(order_item: order_item, coupon: custom_coupon)
        end
      end      
    end
  end
end
