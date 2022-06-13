class Event < ApplicationRecord
  belongs_to :partner
  belongs_to :created_by, class_name: "User"
  belongs_to :city
  belongs_to :state
  belongs_to :approved_by, class_name: "User", foreign_key: "approved_by_id", optional: true

  has_one_attached :photo
  has_one_attached :presentation
  has_many_attached :sponsors_photos
  has_many_attached :supporters_photos

  has_many :event_batches, dependent: :destroy
  has_many :passes, through: :event_batches

  has_many :questions, dependent: :destroy
  has_many :event_communications
  has_many :coupons, as: :entity  
  has_many :accesses
  has_many :membership_discounts
  has_many :memberships, through: :membership_discounts

  has_rich_text :description
  has_rich_text :terms_of_use

  validates :name, :description, :cep, :street_name, :street_number, :neighborhood, :scheduled_start, :scheduled_end, presence: true

  scope :upcoming, -> { where("scheduled_end < ?", Time.current) }
  scope :happening_now, -> { where("scheduled_start > ? and scheduled_end < ?", Time.current, Time.current) }
  scope :past, -> { where("scheduled_end > ?", Time.current) }
  scope :not_approved, -> { where(approved_at: nil, deactivated_at: nil) }
  scope :active, -> { where.not(approved_at: nil).where(deactivated_at: nil) }
  scope :deactivated, -> { where.not(deactivated_at: nil) }

  def active?
    approved_at.present? && deactivated_at.blank?
  end

  def create_default_questions
    Question.create!(
      event: self,
      kind: "open",   
      prompt: "Nome completo",
      optional: false,
      order: questions.count,
      default: true,
    )

    Question.create!(
      event: self,
      kind: "open",
      prompt: "CPF",
      optional: false,
      order: questions.count,
      default: true,
    )

    Question.create!(
      event: self,
      kind: "open",
      prompt: "CEP",
      optional: false,
      order: questions.count,
      default: true,
    )
  end

  def open_batches
    # TODO: Refatorar para uma solução SQL melhor
    
    available_batches = event_batches.select(&:available?)
    available_pass_types = available_batches.pluck(:pass_type).uniq
    
    available_pass_types.map do |pass_type|
      available_batches
        .select { |available_batch| available_batch.pass_type == pass_type}
        .sort_by(&:order)
        .first      
    end
  end

  def passes_csv
    ordered_questions = questions.order("questions.order")
    attributes = ["Email do usuário", "CPF", "Tipo do passe", "Lote", "Valor pago (em centavos)"] + ordered_questions.map(&:prompt)
    CSV.generate(headers: true, encoding: "iso-8859-1") do |csv|
      csv << attributes
      passes.each do |pass|
        csv << [pass.user.email, pass.user.document_number, pass.event_batch.pass_type, pass.event_batch.name, pass.event_batch.price_in_cents] + ordered_questions.map { |question| pass.question_answers.joins(:question).find_by(questions: {id: question.id}).value.gsub(",", " ").gsub("\n", " ").gsub("\r", " ") }
      end
    end
  end

  def full_address
    "#{street_name} - #{street_number} - #{address_complement}, #{neighborhood}, #{city.name} - #{city.state.acronym}"
  end
end
