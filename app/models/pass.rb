class Pass < ApplicationRecord
  belongs_to :user
  belongs_to :order_item, optional: true
  belongs_to :partner
  
  belongs_to :event_batch, optional: true
  belongs_to :day_use_schedule, optional: true
  belongs_to :user_membership, optional: true

  has_one :event, through: :event_batch

  has_many :reads, dependent: :destroy
  has_many :accesses
  has_many :question_answers, through: :order_item

  validates :identifier, :name, presence: true

  scope :for_date, -> (date) { where("passes.start_time > ? and passes.start_time < ?", date.at_beginning_of_day, date.at_end_of_day) }

  def holder_name
    return user.name if user_membership.present?

    return nil if question_answers.blank?

    question_answers.joins(:event_question).find_by(event_questions: {prompt: "Nome completo"}).value
  end

  def holder_cpf
    return user.document_number if user_membership.present? || day_use_schedule.present?

    return nil if question_answers.blank?

    cpf = question_answers.joins(:event_question).find_by(event_questions: {prompt: "CPF"}).value

    cpf.insert(3, ".").insert(7, ".").insert(11, "-")
  end

  def kind
    return "event" if event_batch.present?
    return "day_use" if day_use_schedule.present?
    return "membership" if user_membership.present?

    false
  end

  def status
    if user_membership.present?
      return {
        label: "Ativo",
        class: "bg-success"
      } if user_membership.active?

      return {
        label: "Inativo",
        class: "bg-danger"
      }
    else
      return {
        label: "Não utilizado",
        class: "bg-danger"
      } if end_time < Time.current

      return {
        label: "Utilizado",
        class: "bg-info"
      } if accesses.present?

      return {
        label: "Disponível",
        class: "bg-success"
      } 
    end
  end
end
