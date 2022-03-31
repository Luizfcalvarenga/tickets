class Order < ApplicationRecord
  belongs_to :user
  belongs_to :created_by, class_name: "User", foreign_key: "created_by_id", optional: true
  belongs_to :directly_generated_by, class_name: "User", foreign_key: "directly_generated_by_id", optional: true

  has_many :order_items
  has_many :passes, through: :order_items

  accepts_nested_attributes_for :user

  def related_entity
    sample_order_item = order_items.first
    if sample_order_item.day_use_schedule_pass_type.present?
      sample_order_item.day_use_schedule_pass_type.day_use
    elsif sample_order_item.event_batch.present?
      sample_order_item.event_batch.event
    else 
      raise
    end
  end

  def total_price_in_cents
    order_items.sum(:total_in_cents)
  end

  def total_price_is_zero?
    total_price_in_cents.zero?
  end

  def nova_iugu_charge_params_hash
    {
      email: user.email,
      months: 1,
      items: order_items.map do |order_item|
        {
          description: "Ingresso para: #{order_item.full_description}",
          quantity: 1,
          price_cents: order_item.total_in_cents,
        }
      end,
      payer: {
        name: user.name,
      },
      ignore_due_email: true,
      ignore_canceled_email: true,  
      due_date: (Time.current + 10.days),  
      payable_with: ["pix", "credit_card"]
    }
  end

  def perform_after_payment_confirmation_actions
    OrderPassesGenerator.new(self).call
    self.update(status: "paid")
    DiscordMessager.call("Nova compra realizada: R$ #{ActionController::Base.helpers.number_to_currency(total_price_in_cents.to_f/100, unit: "R$", separator: ",", delimiter: ".")}")
  end

  def check_payment_actions_performed
    status === "paid" && passes.count === order_items.count
  end
end
