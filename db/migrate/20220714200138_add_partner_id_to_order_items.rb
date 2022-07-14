class AddPartnerIdToOrderItems < ActiveRecord::Migration[6.1]
  def change
    add_reference :order_items, :partner, foreign_key: true

    OrderItem.find_each do |order_item|
      order_item.update(partner: order_item.related_entity.partner)
    end
  end
end
