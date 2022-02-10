class Pass < ApplicationRecord
  belongs_to :user
  belongs_to :order_item
  belongs_to :partner
  
  belongs_to :event_batch, optional: true
  belongs_to :day_use_schedule, optional: true
  belongs_to :membership, optional: true

  has_one :event, through: :event_batch

  has_many :reads
  has_many :question_answers, through: :order_item

  validates :identifier, :name, presence: true
end
