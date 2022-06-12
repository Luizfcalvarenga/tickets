class Order < ApplicationRecord
  belongs_to :user
  belongs_to :created_by, class_name: "User", foreign_key: "created_by_id", optional: true
  belongs_to :directly_generated_by, class_name: "User", foreign_key: "directly_generated_by_id", optional: true
  belongs_to :coupon, optional: true

  has_many :order_items
  has_many :passes, through: :order_items

  accepts_nested_attributes_for :user

  scope :paid, -> { where(status: "paid")}

  INSTALLMENT_TAX_PERCENTAGE = 3
  MAX_INSTALLMENTS = 12
  
  def related_entity
    order_items.first.related_entity
  end

  def calculate_and_set_financial_values!
    total_price_in_cents = order_items.sum(:total_in_cents) - discount_value_in_cents
    self.update(reference_value_in_cents: total_price_in_cents)
    self.update(amount_to_transfer_to_partner: order_items.map(&:amount_to_transfer_to_partner).sum)
  end

  def is_free?
    reference_value_in_cents.zero?
  end

  def discount_value_in_cents
    order_items.map(&:discount_value_in_cents).sum
  end

  def nova_iugu_charge_params_hash
    {
      email: user.email,
      months: 1,
      items: order_items.map do |order_item|
        {
          description: "Ingresso para: #{order_item.full_description}",
          quantity: 1,
          price_cents: order_item.total_in_cents,
        }
      end,
      discount_cents: discount_value_in_cents,
      payer: {
        name: user.name,
        cpf_cnpj: user.document_number,
        address: {
          zip_code: user.cep,
          number: "-",
        }
      },
      ignore_due_email: true,
      ignore_canceled_email: true,  
      due_date: (Time.current + 10.days),  
      payable_with: ["pix", "credit_card"]
    }
  end

  def installment_options 
    (1..MAX_INSTALLMENTS).map do |installment_count|
      total_value = (reference_value_in_cents * (1 + INSTALLMENT_TAX_PERCENTAGE.to_f/100)**(installment_count - 1))
      {
        count: installment_count,
        value_in_cents: (total_value / installment_count).floor,
        total_value_in_cents: total_value
      }
    end
  end

  def perform_after_payment_confirmation_actions
    OrderPassesGenerator.new(self).call
    self.update(status: "paid")
  end

  def check_payment_actions_performed
    status == "paid" && passes.count == order_items.count
  end

  def should_generate_new_invoice?
    !is_free? && (invoice_id.blank? || invoice_status == "expired" || invoice_status == "canceled")
  end

  def self.to_csv
    attributes = ["Usuário", "Identificação do pedido", "Entidade", "Gerado em", "Preço", "Taxa", "Absorver taxa?", "Valor a receber (R$)"]
    CSV.generate(headers: true, encoding: Encoding::ISO_8859_1) do |csv|
      csv << attributes
      all.each do |order|
       csv << [order.user.email, order.id, order.related_entity.name, order.created_at.strftime("%d/%m/%Y - %H:%M"), ApplicationController.helpers.display_price(order.reference_value_in_cents), "#{order.order_items.first.fee_percentage}%", order.order_items.first.absorb_fee ? "Sim" : "Não", ApplicationController.helpers.display_price(order.amount_to_transfer_to_partner)]
      end
    end
  end
end
