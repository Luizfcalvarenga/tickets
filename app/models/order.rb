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

  def related_partner
    order_items.first.partner
  end

  def amount_to_transfer_to_partner
    order_items.map(&:amount_to_transfer_to_partner).sum
  end

  def price_in_cents
    order_items.map(&:price_in_cents).sum
  end

  def total_in_cents
    order_items.map(&:total_in_cents).sum
  end

  def platform_fee_value_in_cents
    order_items.map(&:platform_fee_value_in_cents).sum
  end

  def displayed_fee_value_in_cents
    order_items.map(&:displayed_fee_value_in_cents).sum
  end

  def fee_percentage
    order_items.first.fee_percentage
  end

  def is_free?
    total_in_cents.zero?
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
      total_value = (price_in_cents * (1 + INSTALLMENT_TAX_PERCENTAGE.to_f/100)**(installment_count - 1))
      {
        count: installment_count,
        value_in_cents: (total_value / installment_count).floor,
        total_value_in_cents: total_value.floor
      }
    end
  end

  def perform_after_payment_confirmation_actions
    if is_free?
      self.update(
        value: 0,
        net_value: 0,
        invoice_paid_at: Time.current
      )
    end
    OrderPassesGenerator.new(self).call
    self.update(status: "paid")
  end

  def check_payment_actions_performed
    status == "paid" && passes.count == order_items.count
  end

  def should_generate_new_invoice?
    !is_free? && (invoice_id.blank? || invoice_status == "expired" || invoice_status == "canceled")
  end

  def self.to_csv(mode = "partner")
    if mode == "partner"
      attributes = ["Usuário", "Identificação do pedido", "Entidade", "Pago em", "Preço", "Cupom", "Descontos", "Taxa", "Absorver taxa?", "Valor a receber (R$)"]
      CSV.generate(headers: true, encoding: Encoding::ISO_8859_1) do |csv|
        csv << attributes
        all.each do |order|
          csv << [order.user.email, 
            order.id, 
            order.related_entity.name, 
            order.invoice_paid_at&.strftime("%d/%m/%Y") || "-", 
            ApplicationController.helpers.display_price(order.price_in_cents), 
            order.coupon&.code || "-", 
            ApplicationController.helpers.display_price(order.discount_value_in_cents), 
            "#{order.fee_percentage}%", 
            order.order_items.first.absorb_fee ? "Sim" : "Não", 
            ApplicationController.helpers.display_price(order.amount_to_transfer_to_partner)]
        end
      end
    elsif mode == "admin"
      attributes = ["Usuário", "Nome do usuário", "Parceiro", "Gerado em", "Absorver taxa?", "Valor de referência", "Descontos", "Taxa da plataforma", "Taxa da plataforma", "Valor cobrado", "Receita líquida", "Taxa da Iugu", "Lucro líquido" ]
      CSV.generate(headers: true, encoding: Encoding::ISO_8859_1) do |csv|
        csv << attributes
        all.each do |order|
          csv << [order.user.email, 
            order.id, 
            order.related_partner.name, 
            order.invoice_paid_at&.strftime("%d/%m/%Y - %H:%M") || "-", 
            order.order_items.first.absorb_fee ? "Sim" : "Não", 
            ApplicationController.helpers.display_price(order.price_in_cents), 
            ApplicationController.helpers.display_price(order.discount_value_in_cents), 
            order.fee_percentage , 
            ApplicationController.helpers.display_price(order.platform_fee_value_in_cents), 
            ApplicationController.helpers.display_price(order.value), 
            ApplicationController.helpers.display_price(order.net_value), 
            ApplicationController.helpers.display_price(order.value - order.net_value), 
            ApplicationController.helpers.display_price(order.net_value - order.amount_to_transfer_to_partner)]
        end
      end
    end
  end
end
