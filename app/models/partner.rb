class Partner < ApplicationRecord
  belongs_to :main_contact, optional: true, class_name: "User"

  has_many :events
  has_many :memberships
end
