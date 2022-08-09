class DayUse < ApplicationRecord
  include ::ModelConcern

  belongs_to :partner
  belongs_to :approved_by, class_name: "User", foreign_key: "approved_by_id", optional: true

  has_rich_text :description
  has_rich_text :terms_of_use
  
  has_one_attached :photo

  has_many :questions
  has_many :day_use_packages
  has_many :day_use_schedules, dependent: :destroy
  has_many :day_use_schedule_pass_types, through: :day_use_schedules, dependent: :destroy
  has_many :passes, through: :day_use_schedule_pass_types
  has_many :day_use_blocks, dependent: :destroy
  has_many :coupons, as: :entity, dependent: :destroy

  scope :open_for_weekday, ->(weekday) { joins(:day_use_schedules).where("day_use_schedules.opens_at is not null and day_use_schedules.closes_at is not null and day_use_schedules.weekday = ?", weekday) }
  scope :not_approved, -> { where(approved_at: nil, deactivated_at: nil) }
  scope :active, -> { where.not(approved_at: nil).where(deactivated_at: nil) }
  scope :deactivated, -> { where.not(deactivated_at: nil) }

  validates :name, :description, presence: true
  validate :must_have_uploaded_photo

  def must_have_uploaded_photo
    if !photo.attached?
      errors.add(:photo, "Deve ser enviado uma imagem para o banner do Agendamento")
    end
  end
  
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
    ) if !Question.exists?(day_use: self, prompt: "Nome completo")

    question = Question.create!(
      day_use: self,
      kind: "open",
      prompt: "CPF",
      optional: false,
      order: questions.count,
      default: true,
    ) if !Question.exists?(day_use: self, prompt: "CPF")

    Question.create!(
      day_use: self,
      kind: "open",
      prompt: "CEP",
      optional: false,
      order: questions.count,
      default: true,
    ) if !Question.exists?(day_use: self, prompt: "CEP")

    Question.create!(
      day_use: self,
      kind: "open",
      prompt: "Telefone",
      optional: false,
      order: questions.count,
      default: true,
    ) if !Question.exists?(day_use: self, prompt: "Telefone")
  end

  def passes_csv
    attributes = ["Email do usuário", "CPF", "Tipo do passe", "Data", "Horário", "Lote", "Valor pago (em centavos)"] + questions.order("questions.order").map(&:prompt)
    CSV.generate(headers: true, encoding: Encoding::UTF_8) do |csv|
      csv << attributes
      passes.each do |pass|
        csv << [pass.user.email, pass.user.document_number, pass.day_use_schedule_pass_type.name, pass.start_time.strftime("%d/%m/%Y"), pass.start_time.strftime("%H:%M"), pass.day_use_schedule_pass_type.price_in_cents] + pass.question_answers.joins(:question).order("questions.order").map(&:value)
      end
    end
  end

  def full_address
    "#{partner.street_name} - #{partner.street_number} - #{partner.address_complement}, #{partner.neighborhood}, #{partner.city.name} - #{partner.city.state.acronym}"
  end

  def display_photo
    photo&.key.present? ? photo.key : partner.logo.key
  end

  def available_passes_per_date
    dates = []
    
    (0..60).to_a.map do |days_ahead|
      date = Time.current + days_ahead.days
      day_use_schedule_for_date = schedule_for_date(date)
      next if !day_use_schedule_for_date.open?

      open_slots_for_date = day_use_schedule_for_date.open_slots_for_date(date)
      
      dates << {
        date: date,
        weekday_display: weekday_translation(weekday_for_wday(date.wday)),
        open_slots_for_date: open_slots_for_date
      } if open_slots_for_date.map { |open_slots| open_slots[:available_pass_types] }.any?(&:present?)
    end
    
    dates
  end
end
