class EventBatch < ApplicationRecord
  belongs_to :event

  validates :price_in_cents, :quantity, :name, presence: true

  has_many :passes
  has_many :event_question_batches
  has_many :event_questions, through: :event_question_batches
  has_many :order_items

  scope :available, -> { where("event_batches.ends_at > now() and (select count(distinct order_items.id) from order_items inner join orders on order_items.order_id = orders.id where order_items.event_batch_id = event_batches.id and (orders.status = 'confirmed' or now()::time > (orders.created_at + interval '10 min')::time)) < event_batches.quantity") }
end
