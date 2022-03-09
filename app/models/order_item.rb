class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :event_batch, optional: true
  belongs_to :day_use_schedule_pass_type, optional: true
  
  has_one :pass, dependent: :destroy

  has_many :question_answers, dependent: :destroy

  def fee_value_in_cents
    price_in_cents * fee_percentage / 100
  end

  def identification_name
    return nil if question_answers.blank?

    question_answers.joins(:question).find_by(questions: {prompt: "Nome completo"}).value
  end

  def identification_cpf
    return nil if question_answers.blank?

    cpf = question_answers.joins(:question).find_by(questions: {prompt: "CPF"}).value

    cpf.insert(3, ".").insert(7, ".").insert(11, "-")
  end

  def full_description
    if event_batch.present?
      return "#{event_batch.event.name} - #{event_batch.pass_type} - #{event_batch.name}"
    elsif day_use_schedule_pass_type.present?
      return "#{day_use_schedule_pass_type.day_use_schedule.day_use.name} - #{day_use_schedule_pass_type.day_use_schedule.name} - #{day_use_schedule_pass_type.name} - #{start_time.strftime("%d/%m/%Y")}"
    else
      raise RecordInvalid
    end
  end

  def questions
    if event_batch.present?
      event_batch.event.questions
    elsif day_use_schedule_pass_type.present?
      day_use_schedule_pass_type.day_use_schedule.day_use.questions
    else
      raise
    end
  end
end
