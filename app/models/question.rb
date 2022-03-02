class Question < ApplicationRecord
  belongs_to :event, optional: true
  belongs_to :day_use, optional: true

  has_many :question_batches

  scope :non_default, -> { where(default: false) }

  enum kind: {
    multiple_choice: "multiple_choice",
    open: "open",
  }
  
  scope :non_default_questions, -> { where.not(prompt: ["Nome completo", "CPF"])}
  scope :default_questions, -> { where(prompt: ["Nome completo", "CPF"])}
end
