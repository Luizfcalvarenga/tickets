class EventQuestion < ApplicationRecord
  belongs_to :event

  has_many :event_question_batches

  enum kind: {
    multiple_choice: "multiple_choice",
    open: "open",
  }
end
