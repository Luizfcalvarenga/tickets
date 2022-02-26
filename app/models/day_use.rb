class DayUse < ApplicationRecord
  belongs_to :partner

  has_rich_text :description

  has_one_attached :photo

  has_many :questions

  has_many :day_use_schedules, dependent: :destroy
  has_many :day_use_schedule_pass_types, through: :day_use_schedules, dependent: :destroy
  has_many :passes, through: :day_use_schedule_pass_types
  has_many :day_use_blocks, dependent: :destroy

  scope :open_for_weekday, ->(weekday) { joins(:day_use_schedules).where("day_use_schedules.opens_at is not null and day_use_schedules.closes_at is not null and day_use_schedules.weekday = ?", weekday) }

  def schedule_for_today
    day_use_schedules.find_by(weekday: Time.current.strftime("%A").downcase)
  end

  def create_default_questions
    question = Question.create!(
      day_use: self,
      kind: "open",   
      prompt: "Nome completo",
      optional: false,
      order: questions.count,
    )

    question = Question.create!(
      day_use: self,
      kind: "open",
      prompt: "CPF",
      optional: false,
      order: questions.count,
    )
  end

  def passes_csv
    attributes = ["Nome", "Email", "Documento", "Número do Documento", "Acesso", "Tipo do passe", "Lote", "Valor pago"] + questions.order("questions.order").map(&:prompt)
    CSV.generate(headers: true) do |csv|
      csv << attributes
      passes.each do |pass|
        csv << [pass.user.name, pass.user.email, pass.user.document_type, pass.user.document_number, nil, pass.event_batch.pass_type, pass.event_batch.name, pass.event_batch.price_in_cents] + pass.question_answers.joins(:question).order("questions.order").map(&:value)
      end
    end
  end
end
