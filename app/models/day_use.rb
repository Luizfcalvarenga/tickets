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

  def schedule_for_date(date)
    day_use_schedules.find_by(weekday: date.strftime("%A").downcase)
  end

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
      default: true,
    )

    question = Question.create!(
      day_use: self,
      kind: "open",
      prompt: "CPF",
      optional: false,
      order: questions.count,
      default: true,
    )

    Question.create!(
      day_use: self,
      kind: "open",
      prompt: "CEP",
      optional: false,
      order: questions.count,
      default: true,
    )
  end

  def passes_csv
    attributes = ["Email do usuário", "CPF", "Tipo do passe", "Data", "Horário", "Lote", "Valor pago (em centavos)"] + questions.order("questions.order").map(&:prompt)
    CSV.generate(headers: true) do |csv|
      csv << attributes
      passes.each do |pass|
        csv << [pass.user.email, pass.user.document_number, pass.day_use_schedule_pass_type.name, pass.start_time.strftime("%d/%m/%Y"), pass.start_time.strftime("%H:%M"), pass.day_use_schedule_pass_type.price_in_cents] + pass.question_answers.joins(:question).order("questions.order").map(&:value)
      end
    end
  end
end
