class OrderPassesGenerator
  attr_reader :order

  def initialize(order)
    @order = order
  end
  
  def call
    @order.order_items.each do |order_item|
      next if Pass.exists?(order_item: order_item)

      # identifier = "#{"%04d" %  order_item.order.user_id}#{"%04d" %  order_item.order.user.passes.count}"
      identifier = SecureRandom.uuid

      partner_id = if order_item.event_batch.present?
        order_item.event_batch.event.partner_id
      elsif order_item.day_use_schedule.present?
        order_item.day_use_schedule.day_use.partner_id
      end

      pass = Pass.create(
        identifier: identifier,
        name: order_item.full_description,
        partner_id: partner_id,
        event_batch_id: order_item.event_batch_id,
        day_use_schedule_id: order_item.day_use_schedule_id,
        user: order_item.order.user,
        order_item: order_item,
        start_time: order_item.start_time,
        end_time: order_item.end_time,
        price_in_cents: order_item.price_in_cents,
        fee_percentage: order_item.fee_percentage,
        qrcode_svg: RQRCode::QRCode.new(identifier).as_svg(
          color: "000",
          shape_rendering: "crispEdges",
          module_size: 5,
          standalone: true,
          use_path: true,
        ),
      )
    end
  end

  private

  def next_date_for_weekday(weekday_name)
    return Date.today if Time.current.strftime("%A").downcase.to_sym == weekday_name.downcase.to_sym

    Date.today.next_occurring(weekday_name.downcase.to_sym)
  end
end
