class OrderPassesGenerator
  attr_reader :order

  def initialize(order)
    @order = order
  end
  
  def call
    @order.order_items.each do |order_item|
      # identifier = "#{"%04d" %  order_item.order.user_id}#{"%04d" %  order_item.order.user.passes.count}"
      identifier = SecureRandom.uuid

      name = if order_item.event_batch.present?
        "#{order_item.event_batch.event.name} - #{order_item.event_batch.pass_type} - #{order_item.event_batch.name}"
      elsif order_item.day_use_schedule.present?
        "#{order_item.day_use_schedule.day_use.name} - #{order_item.day_use_schedule.name} - #{order_item.start_time.strftime("%d/%m/%Y")}"
      end

      partner_id = if order_item.event_batch.present?
        order_item.event_batch.event.partner_id
      elsif order_item.day_use_schedule.present?
        order_item.day_use_schedule.day_use.partner_id
      end

      pass = Pass.create(
        identifier: identifier,
        name: name,
        partner_id: partner_id,
        event_batch_id: order_item.event_batch_id,
        day_use_schedule_id: order_item.day_use_schedule_id,
        user: order_item.order.user,
        order_item: order_item,
        start_time: order_item.start_time,
        end_time: order_item.end_time,
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
