class Partner < ApplicationRecord
  belongs_to :main_contact, optional: true, class_name: "User"
  belongs_to :city
  belongs_to :state
  
  has_many :events
  has_many :memberships
end
