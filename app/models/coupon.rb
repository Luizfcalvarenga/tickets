class Coupon < ApplicationRecord
  belongs_to :entity, polymorphic: true

  has_many :orders

  enum kind: {
    percentage: "percentage",
    fixed: "fixed",
  }

  def discount_display
    if percentage?
      "#{discount}%"
    elsif fixed?
      ApplicationController.helpers.display_price(discount)
    else 
      raise
    end
  end
end
