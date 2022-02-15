class Pass < ApplicationRecord
  belongs_to :user
  belongs_to :order_item, optional: true
  belongs_to :partner
  
  belongs_to :event_batch, optional: true
  belongs_to :day_use_schedule, optional: true
  belongs_to :user_membership, optional: true

  has_one :event, through: :event_batch

  has_many :reads
  has_many :accesses
  has_many :question_answers, through: :order_item

  validates :identifier, :name, presence: true

  def holder_name
    return user.name if user_membership.present?

    return nil if question_answers.blank?

    question_answers.joins(:event_question).find_by(event_questions: {prompt: "Nome completo"}).value
  end

  def holder_cpf
    return user.document_number if user_membership.present? || day_use_schedule.present?

    return nil if question_answers.blank?

    question_answers.joins(:event_question).find_by(event_questions: {prompt: "CPF"}).value
  end

  def kind
    return "event" if event_batch.present?
    return "day_use" if day_use_schedule.present?
    return "membership" if user_membership.present?

    false
  end
end
