class DayUsePackage < ApplicationRecord
  belongs_to :day_use
  belongs_to :created_by, class_name: "User", foreign_key: "created_by_id"

  has_many :day_use_package_pass_types
  has_many :day_use_schedule_pass_types, through: :day_use_package_pass_types

  scope :active, -> { where(deactivated_at: nil) }

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

  def deactivated?
    deactivated_at.present?
  end
end
