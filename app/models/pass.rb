class Pass < ApplicationRecord
  belongs_to :user
  belongs_to :order_item
  
  belongs_to :event_batch, optional: true
  belongs_to :day_use, optional: true
  belongs_to :membership, optional: true

  has_one :event, through: :event_batch

  has_many :reads

  validates :identifier, presence: true
end
