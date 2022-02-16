class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :event_batch, optional: true
  belongs_to :day_use_schedule, optional: true
  
  has_one :pass, dependent: :destroy

  has_many :question_answers, dependent: :destroy

  def full_description
    if event_batch.present?
      return "#{event_batch.event.name} - #{event_batch.pass_type} - #{event_batch.name}"
    elsif day_use_schedule.present?
      return "#{day_use_schedule.day_use.name} - #{day_use_schedule.name} - #{start_time.strftime("%d/%m/%Y")}"
    else
      raise RecordInvalid
    end
  end
end
