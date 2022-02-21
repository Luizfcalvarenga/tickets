class Event < ApplicationRecord
  belongs_to :partner
  belongs_to :created_by, class_name: "User"
  belongs_to :city
  belongs_to :state

  has_one_attached :photo
  has_many :event_batches, dependent: :destroy
  has_many :passes, through: :event_batches

  has_many :event_questions, dependent: :destroy
  has_many :event_communications
  
  has_many :accesses
  has_many :membership_discounts
  has_many :memberships, through: :membership_discounts

  has_rich_text :description

  scope :upcoming, -> { where("scheduled_end < ?", Time.current) }
  scope :happening_now, -> { where("scheduled_start > ? and scheduled_end < ?", Time.current, Time.current) }
  scope :past, -> { where("scheduled_end > ?", Time.current) }

  def create_default_event_questions
    event_question = EventQuestion.create!(
      event: self,
      kind: "open",
      prompt: "Nome completo",
      optional: false,
      order: event_questions.count,
    )
    event_batches.each do |event_batch|
      EventQuestionBatch.create(event_batch: event_batch, event_question: event_question)
    end

    event_question = EventQuestion.create!(
      event: self,
      kind: "open",
      prompt: "CPF",
      optional: false,
      order: event_questions.count,
    )
    event_batches.each do |event_batch|
      EventQuestionBatch.create(event_batch: event_batch, event_question: event_question)
    end
  end

  def open_batches
    event_batches.available.pluck(:pass_type).uniq.map do |pass_type|
      event_batches.available.where(pass_type: pass_type).order(:order).first      
    end
  end

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
