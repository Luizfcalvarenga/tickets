class MembershipDiscount < ApplicationRecord
  belongs_to :event, optional: true
  belongs_to :day_use, optional: true
  belongs_to :membership
end
