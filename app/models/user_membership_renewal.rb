class UserMembershipRenewal < ApplicationRecord
  belongs_to :user_membership

  has_one :order_item

  delegate :membership, to: :user_membership
end
