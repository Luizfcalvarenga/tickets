class Pass < ApplicationRecord
  belongs_to :user
  belongs_to :order_item, optional: true
  belongs_to :partner
  belongs_to :directly_generated_by, class_name: "User", foreign_key: "directly_generated_by_id", optional: true
  
  belongs_to :event_batch, optional: true
  belongs_to :day_use_schedule_pass_type, optional: true
  belongs_to :user_membership, optional: true

  has_one :event, through: :event_batch

  has_many :reads, dependent: :destroy
  has_many :accesses
  has_many :question_answers, through: :order_item
  
  has_one_attached :pdf_pass

  validates :identifier, :name, presence: true

  scope :for_date, -> (date) { where("passes.start_time >= ? and passes.start_time < ?", date.at_beginning_of_day, date.at_end_of_day) }
  scope :after_date, -> (date) { where("passes.start_time >= ?", date.at_beginning_of_day) }
  scope :fee_absorbed, -> { where(absorb_fee: true) }
  scope :fee_not_absorbed, -> { where(absorb_fee: false) }
  scope :not_free, -> { where(free: false) }
  scope :from_event_or_day_use, -> { where("event_batch_id is not null OR day_use_schedule_pass_type_id is not null") }
  scope :active, -> { where(deactivated_at: nil) }

  def order
    order_item.order
  end

  def tax_amount
    price_in_cents * (fee_percentage/100)
  end

  def revenue_from_pass
    absorb_fee ? price_in_cents : (price_in_cents + tax_amount)
  end

  def amount_to_transfer_to_partner
    absorb_fee ? (price_in_cents - tax_amount) : price_in_cents
  end

  def holder_name
    return user.name if user_membership.present?

    return nil if question_answers.blank?

    question_answers.joins(:question).find_by(questions: {prompt: "Nome completo"}).value
  end

  def holder_cpf
    return user.document_number if user_membership.present? || day_use_schedule_pass_type.present?

    return nil if question_answers.blank?

    cpf = question_answers.joins(:question).find_by(questions: {prompt: "CPF"}).value

    cpf.insert(3, ".").insert(7, ".").insert(11, "-")
  end

  def kind
    return "event" if event_batch.present?
    return "day_use" if day_use_schedule_pass_type.present?
    return "membership" if user_membership.present?

    false
  end

  def related_entity
    if day_use_schedule_pass_type.present?
      day_use_schedule_pass_type.day_use
    elsif event_batch.present?
      event_batch.event
    elsif user_membership.present?
      user_membership.membership
    end
  end

  def full_address
    related_entity.full_address
  end

  def status
    if user_membership.present?
      return {
        label: "Ativo",
        class: "text-success"
      } if user_membership.active?

      return {
        label: "Inativo",
        class: "text-secondary"
      }
    else
      return {
        label: "Desativado",
        class: "text-danger"
      } if deactivated_at.present?

      return {
        label: "Utilizado",
        class: "text-secondary"
      } if accesses.present?

      return {
        label: "Não utilizado",
        class: "text-danger"
      } if end_time.at_end_of_day < Time.current

      return {
        label: "Disponível",
        class: "text-success"
      } 
    end
  end

  def self.to_csv
    attributes = ["Email do usuário", "Nome do passe", "Entidade", "Participante", "Gerado em", "Preço cadastrado", "Preço para consumidor final", "Taxa (%)", "Valor a receber (R$)"]
    CSV.generate(headers: true, encoding: Encoding::ISO_8859_1) do |csv|
      csv << attributes
      all.each do |pass|
       csv << [pass.user.email, pass.name, pass.related_entity.name, "#{pass.holder_name} - #{pass.holder_cpf}", pass.created_at, ApplicationController.helpers.display_price(pass.price_in_cents), ApplicationController.helpers.display_price(pass.revenue_from_pass), "#{pass.fee_percentage}%", ApplicationController.helpers.display_price(pass.amount_to_transfer_to_partner)]
      end
    end
  end
end
