class Coupon < ApplicationRecord
  belongs_to :entity, polymorphic: true

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

  def limit_reached?
    orders.count >= redemption_limit
  end

  def expired?
    valid_until.at_end_of_day < Time.current.at_end_of_day
  end

  def can_be_applied?
    !deactivated? && !limit_reached? && !expired?
  end
end
