class Coupon < ApplicationRecord
  belongs_to :entity, polymorphic: true, optional: true
  belongs_to :day_use_package, optional: true

  has_many :orders

  enum kind: {
    percentage: "percentage",
    fixed: "fixed",
  }

  scope :active, -> { where(deactivated_at: nil) }

  def discount_display
    if percentage?
      "#{discount}%"
    elsif fixed?
      ApplicationController.helpers.display_price(discount)
    else 
      raise
    end
  end

  def deactivated?
    deactivated_at.present?
  end

  def utilization_count
    OrderItem.where(order_id: orders.paid.ids).count
  end

  def limit_reached?
    utilization_count >= redemption_limit
  end

  def expired?
    valid_until.at_end_of_day < Time.current.at_end_of_day
  end

  def can_be_applied?
    !deactivated? && !limit_reached? && !expired?
  end
end
