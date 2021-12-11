class Membership < ApplicationRecord
  belongs_to :partner

  has_many :user_memberships
  has_many :users, through: :user_memberships
end
