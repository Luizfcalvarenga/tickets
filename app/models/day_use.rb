class DayUse < ApplicationRecord
  belongs_to :partner

  has_rich_text :description

  has_one_attached :photo

  has_many :day_use_schedules, dependent: :destroy
  has_many :passes, through: :day_use_schedules
  has_many :day_use_blocks, dependent: :destroy


  scope :open_for_weekday, ->(weekday) { joins(:day_use_schedules).where("day_use_schedules.start_time is not null and day_use_schedules.end_time is not null and day_use_schedules.weekday = ?", weekday) }

  def passes_csv
    attributes = ["Nome", "Email", "Documento", "Número do Documento", "Acesso", "Tipo do passe", "Lote", "Valor pago"] + event_questions.order("event_questions.order").map(&:prompt)
    CSV.generate(headers: true) do |csv|
      csv << attributes
      passes.each do |pass|
        csv << [pass.user.name, pass.user.email, pass.user.document_type, pass.user.document_number, nil, pass.event_batch.pass_type, pass.event_batch.name, pass.event_batch.price_in_cents] + pass.question_answers.joins(:event_question).order("event_questions.order").map(&:value)
      end
    end
  end
end
