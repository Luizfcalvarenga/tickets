class CouponOrderItem < ApplicationRecord
  belongs_to :coupon
  belongs_to :order_item
end
