class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :event_batch, optional: true
  belongs_to :day_use_schedule, optional: true
  
  has_one :pass, dependent: :destroy

  has_many :question_answers, dependent: :destroy
end
