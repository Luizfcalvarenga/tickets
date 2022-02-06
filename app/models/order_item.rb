class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :event_batch, optional: true
  belongs_to :day_use, optional: true
end
