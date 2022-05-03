class Question < ApplicationRecord
  belongs_to :event, optional: true
  belongs_to :day_use, optional: true

  has_many :question_batches

  validates :kind, :prompt, presence: true
  validate :multiple_choice_question_must_have_at_least_two_options

  def multiple_choice_question_must_have_at_least_two_options
    if kind == "multiple_choice" && options.present? && options.length < 2
      errors.add(:options, "A pergunta de multipla escolha deve ter pelo menos duas opções")
    end
  end

  scope :non_default, -> { where(default: false) }
  scope :default, -> { where(default: true) }

  enum kind: {
    multiple_choice: "multiple_choice",
    open: "open",
  }

  def create_answer_for_order_item_based_on_user_account(order_item)
    if prompt == "Nome completo"
      value = order_item.order.user.name
    elsif prompt == "CPF"
      value = order_item.order.user.document_number
    elsif prompt == "CEP"
      value = order_item.order.user.cep
    else
    end

    QuestionAnswer.create!(
      order_item: order_item,
      question: self,
      value: value,
    )
  end
end
