class QuestionAnswer < ApplicationRecord
  belongs_to :event_question
  belongs_to :order_item

  validates :value, presence: true, unless: :event_question_is_optional

  def event_question_is_optional
    event_question.optional
  end
end
