class MembershipEvent < ApplicationRecord
  belongs_to :event
  belongs_to :membership
end
