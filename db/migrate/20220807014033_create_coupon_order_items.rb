class CreateCouponOrderItems < ActiveRecord::Migration[6.1]
  def change
    create_table :coupon_order_items do |t|
      t.references :coupon, null: false, foreign_key: true
      t.references :order_item, null: false, foreign_key: true

      t.timestamps
    end

    Order.where.not(coupon_id: nil).find_each do |order|
      order.order_items.each do |order_item|
        CouponOrderItem.create(order_item: order_item, coupon: order.coupon)
      end
    end
  end
end
