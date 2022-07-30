class OrderPassesGenerator
  attr_reader :order

  def initialize(order)
    @order = order
  end
  
  def call
    success = false
    
    ActiveRecord::Base.transaction do
      success = @order.order_items.each do |order_item|
        next if Pass.exists?(order_item: order_item)

        identifier = SecureRandom.uuid

        partner_id = if order_item.event_batch.present?
          order_item.event_batch.event.partner_id
        elsif order_item.day_use_schedule_pass_type.present?
          order_item.day_use_schedule_pass_type.day_use_schedule.day_use.partner_id
        end

        pass = Pass.new(
          identifier: identifier,
          name: order_item.full_description,
          partner_id: partner_id,
          event_batch_id: order_item.event_batch_id,
          day_use_schedule_pass_type_id: order_item.day_use_schedule_pass_type_id,
          user: order_item.order.user,
          order_item: order_item,
          start_time: order_item.start_time,
          end_time: order_item.end_time,
          price_in_cents: order_item.price_in_cents,
          fee_percentage: order_item.fee_percentage,
          absorb_fee: order_item.absorb_fee,
          directly_generated_by: order_item.order.directly_generated_by,
          free: order_item.order.free,
          qrcode_svg: RQRCode::QRCode.new(identifier).as_svg(
            color: "000",
            shape_rendering: "crispEdges",
            module_size: 5,
            standalone: true,
            use_path: true,
          ),
        )

        pass.save
      end.all?
    end

    if success
      # TODO: This code tries to prevent one order item from generating more than one pass.
      # Refactor this service to prevent duplicates in a better way
      @order.passes.each do |pass|
        if @order.passes.order(:created_at).find_by(order_item_id: pass.order_item_id) == pass
          PassConfirmationSenderJob.perform_later(pass.id)

          DiscordMessager.call("Novo passe comprado (ID ##{pass.id}): #{pass.order_item.full_description}. Valor: #{ActionController::Base.helpers.number_to_currency(pass.order_item.price_in_cents.to_f/100, unit: "R$", separator: ",", delimiter: ".")}")
        else
          pass.destroy
        end
      end  

      related_entity = order.related_entity
      if related_entity.class == Event && related_entity.group_buy
        related_entity.update!(group_buy_code: (1..12).to_a.map { ("A".."Z").to_a.sample }.join) if related_entity.group_buy_code.blank?
        order.passes.update_all(group_buy_code: related_entity.group_buy_code)
      end
    else
      raise
      return false
    end
  end

  private

  def next_date_for_weekday(weekday_name)
    return Date.today if Time.current.strftime("%A").downcase.to_sym == weekday_name.downcase.to_sym

    Date.today.next_occurring(weekday_name.downcase.to_sym)
  end
end
