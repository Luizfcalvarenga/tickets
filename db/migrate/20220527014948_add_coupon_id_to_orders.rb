class AddCouponIdToOrders < ActiveRecord::Migration[6.1]
  def change
    add_reference :orders, :coupon
  end
end
