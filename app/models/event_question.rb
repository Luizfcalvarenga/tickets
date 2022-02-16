class EventQuestion < ApplicationRecord
  belongs_to :event

  has_many :event_question_batches

  enum kind: {
    multiple_choice: "multiple_choice",
    open: "open",
  }
  
  scope :non_default_questions, -> { where.not(prompt: ["Nome completo", "CPF"])}
  scope :default_questions, -> { where(prompt: ["Nome completo", "CPF"])}
end
