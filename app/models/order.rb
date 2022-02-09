class Order < ApplicationRecord
  belongs_to :user
  belongs_to :created_by, class_name: "User", foreign_key: "created_by_id", optional: true

  has_many :order_items

  def total_price_in_cents
    order_items.sum(:price_in_cents)
  end

  def event_related_to_order_items
    order_items.where.not(event_batch_id: nil).first.event_batch.event
  end

  def has_any_event_questions?
    EventQuestion.joins(event_question_batches: [event_batch: :order_items]).where(order_items: {order_id: id}).present?
  end
end
