class EventBatch < ApplicationRecord
  belongs_to :event

  validates :price_in_cents, :quantity, :name, :pass_type, :number_of_accesses_granted, presence: true

  has_many :passes
  has_many :event_batch_questions
  has_many :questions, through: :event_batch_questions
  has_many :order_items

  scope :available, -> { where("(event.batches.removed_at IS NULL) AND (event_batches.ends_at is null OR event_batches.ends_at > now()) and (select count(distinct order_items.id) from order_items inner join orders on order_items.order_id = orders.id where order_items.event_batch_id = event_batches.id and (orders.status = 'paid' or now()::time < (orders.created_at + interval '10 min')::time)) < event_batches.quantity") }
  scope :active, -> { where(removed_at: nil) }

  delegate :partner, :fee_percentage, :absorb_fee, to: :event

  def total_in_cents
    event.absorb_fee ? price_in_cents : (price_in_cents * (1 + event.fee_percentage / 100))
  end

  def start_time(opt = '')
    event.scheduled_start
  end

  def end_time(opt = '')
    event.scheduled_end
  end

  def in_sales?
    event.open_batches.find { |open_batch| open_batch.id == id }
  end

  def available?
    removed_at.blank? && (ends_at.blank? || ends_at.end_of_day > Time.current) && Pass.where(event_batch_id: id).count < quantity
  end

  def ended_at_datetime
    return nil if available? || ends_at.blank?

    return ends_at.end_of_day if ends_at.end_of_day < Time.current

    return updated_at if quantity == 0
    
    order_items.order(:created_at).last.created_at
  end
end
