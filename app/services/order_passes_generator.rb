class OrderPassesGenerator
  attr_reader :order

  def initialize(order)
    @order = order
  end
  
  def call
    @order.order_items.each do |order_item|
      # identifier = "#{"%04d" %  order_item.order.user_id}#{"%04d" %  order_item.order.user.passes.count}"
      identifier = SecureRandom.uuid

      Pass.create(
        identifier: identifier,
        event_batch_id: order_item.event_batch_id,
        day_use_id: order_item.day_use_id,
        user: order_item.order.user,
        order_item: order_item,
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
end
