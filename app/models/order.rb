class Order < ApplicationRecord
  belongs_to :user
  belongs_to :created_by, class_name: "User", foreign_key: "created_by_id", optional: true

  has_many :order_items
  has_many :passes, through: :order_items

  def total_price_in_cents
    order_items.sum(:price_in_cents)
  end

  def event_related_to_order_items
    order_items.where.not(event_batch_id: nil).first.event_batch.event
  end

  def has_any_event_questions?
    EventQuestion.joins(event_question_batches: [event_batch: :order_items]).where(order_items: {order_id: id}).present?
  end

  def free?
    false
  end

  def nova_iugu_charge_params_hash
    {
      email: user.email,
      months: 1,
      items: order_items.map do |order_item|
        {
          description: "Ingresso para: #{order_item.full_description}",
          quantity: 1,
          price_cents: order_item.price_in_cents,
        }
      end,
      payer: {
        name: user.name,
      },
      ignore_due_email: true,
      ignore_canceled_email: true,  
      due_date: (Time.current + 10.days),  
      payable_wht: ["pix", "credit_card"]
    }
  end

  def perform_after_payment_confirmation_actions
    OrderPassesGenerator.new(self).call
    self.update(status: "paid")
  end

  def check_payment_actions_performed
    status === "paid" && passes.count === order_items.count
  end
end
