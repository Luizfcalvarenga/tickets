require "iugu"

module NovaIugu
  ::Iugu.api_key = ENV["IUGU_API_KEY"]

  class InvoiceGenerator
    attr_reader :entity

    def initialize(entity)
      @entity = entity
    end

    def call
      @response = ::Iugu::Invoice.create(charge_params)

      if @response.errors.blank?
        @entity.update!(
          invoice_id: @response.attributes["id"],
          invoice_url: @response.attributes["secure_url"],
          invoice_pdf: "#{@response.attributes["secure_url"]}.pdf",
          invoice_status: @response.attributes["status"],
          invoice_pix_qrcode_url: @response.attributes["pix"]["qrcode"],
          invoice_pix_qrcode_text: @response.attributes["pix"]["qrcode_text"],
        )
      else
        raise
      end
    end

    def validate_params!
      # raise ChargerParamsException.new("User email (string) not specified at [:email]") if charge_params[:email].blank?
      # raise ChargerParamsException.new("Months (int) not specified at [:months]") if charge_params[:months].blank?
      # raise ChargerParamsException.new("Items (array) not specified at [:items]") if charge_params[:items].blank?

      charge_params[:items].each_with_index do |item, index|
        raise ChargerParamsException.new("Property 'description' (string) not specified for item with index #{index} at [:items]. Item trace: #{item.to_s}") if item[:description].blank?
        raise ChargerParamsException.new("Property 'quantity' (string) not specified for item with index #{index} at [:items]. Item trace: #{item.to_s}") if item[:quantity].blank?
        raise ChargerParamsException.new("Property 'price_cents' (string) not specified for item with index #{index} at [:items]. Item trace: #{item.to_s}") if item[:price_cents].blank?
      end

      raise ChargerParamsException.new("Payer not specified at [:payer]") if charge_params[:payer].blank?
      raise ChargerParamsException.new("Property 'name' (string) not specified for object payer at [:payer]. Item trace: #{charge_params[:payer].to_s}") if charge_params[:payer][:name].blank?
      raise ChargerParamsException.new("Property 'name' (string) not specified for object payer at [:payer]. Item trace: #{charge_params[:payer].to_s}") if charge_params[:payer][:name].blank?
      raise ChargerParamsException.new("Payable With not specified at [:payable_with] or not an option of 'all', 'credit_card', 'bank_slip' or 'pix'") if charge_params[:payable_with].blank? || !['all', 'pix', 'credit_card', 'bank_slip'].include?(charge_params[:payable_with])
    end

    def charge_params
      @charge_params ||= @entity.nova_iugu_charge_params_hash
    end
  end

  class PlanCreator
    attr_reader :entity, :custom_params

    class PlanParamsException < StandardError
      def initialize(error_message)
        @exception_type = "custom"
        super(error_message)
      end
    end
    
    def initialize(entity, custom_params = {})
      @entity = entity
      @custom_params = custom_params
    end

    def call
      raise "Entity already has a Iugu Plan ID" if entity.iugu_plan_id.present?

      validate_params!

      @response = ::Iugu::Plan.create(plan_params)

      entity.update!(
        iugu_plan_id: @response.attributes["id"],
      )
    end

    def validate_params!
      raise PlanParamsException.new("Plan name (string) not specified at [:name]") if plan_params[:name].blank?
      raise PlanParamsException.new("Plan unique identifier (int) not specified at [:identifier]") if plan_params[:identifier].blank?
      raise PlanParamsException.new("Interval (int) not specified at [:interval] or not an integer bigger than 0") if plan_params[:interval].blank? || plan_params[:interval].class != Integer || plan_params[:interval] <= 0
      raise PlanParamsException.new("Interval type not specified at [:interval_type] or not 'weeks' nor 'months'") if plan_params[:interval_type].blank? || !["weeks", "months"].include?(plan_params[:interval_type])
      raise PlanParamsException.new("Value cents not specified at [:value_cents] or not an integer bigger than 0") if plan_params[:value_cents].blank? || plan_params[:value_cents].class != Integer || plan_params[:value_cents] <= 0
      raise PlanParamsException.new("Payable With not specified at [:payable_with] or not an option of 'all', 'credit_card', 'bank_slip' or 'pix'") if plan_params[:payable_with].blank? || !['all', 'pix', 'credit_card', 'bank_slip'].include?(plan_params[:payable_with])
    end

    def plan_params
      @plan_params ||= @entity.nova_iugu_plan_params_hash.merge(custom_params)
    end
  end

  class CustomerCreator
    attr_reader :entity, :custom_params

    class CustomerParamsException < StandardError
      def initialize(error_message)
        @exception_type = "custom"
        super(error_message)
      end
    end
    
    def initialize(entity, custom_params = {})
      @entity = entity
      @custom_params = custom_params
    end

    def call
      return if entity.iugu_customer_id.present?

      validate_params!

      begin
        @response = ::Iugu::Customer.create(customer_params)
      rescue OpenSSL::SSL::SSLError
        sleep 3
        @response = ::Iugu::Customer.create(customer_params)
      end

      entity.update!(
        iugu_customer_id: @response.attributes["id"],
      )
    end

    def validate_params!
      raise CustomerParamsException.new("Customer name (string) not specified at [:name]") if customer_params[:name].blank?
      raise CustomerParamsException.new("Customer email (string) not specified at [:email]") if customer_params[:email].blank?
    end

    def customer_params
      @customer_params ||= @entity.nova_iugu_customer_params_hash.merge(custom_params)
    end
  end

  class SubscriptionCreator
    attr_reader :entity, :custom_params

    class SubscriptionParamsException < StandardError
      def initialize(error_message)
        @exception_type = "custom"
        super(error_message)
      end
    end
    
    def initialize(entity, custom_params = {})
      @entity = entity
      @custom_params = custom_params
    end

    def call
      raise "Entity already has a Iugu Subscription ID" if entity.iugu_subscription_id.present?

      validate_params!

      begin
        @response = ::Iugu::Subscription.create(subscription_params)
      rescue RestClient::BadGateway
        sleep 3
        @response = ::Iugu::Subscription.create(subscription_params)
      rescue Net::ReadTimeout
        sleep 3
        @response = ::Iugu::Subscription.create(subscription_params)
      end

      if !@response.errors.present?
        entity.update!(
          iugu_subscription_id: @response.attributes["id"],
          iugu_active: @response.attributes["active"],
        )
        return true
      else
        return false
      end
    end

    def validate_params!
      raise SubscriptionParamsException.new("Plan identifier (string) not specified at [:plan_identifier]") if subscription_params[:plan_identifier].blank?
      raise SubscriptionParamsException.new("Customer ID (string) not specified at [:customer_id]") if subscription_params[:customer_id].blank?
    end

    def subscription_params
      @subscription_params ||= @entity.nova_iugu_subscription_params_hash.merge(custom_params)
    end
  end

  class DirectPayer
    attr_reader :entity, :customer_payment_method_id, :number_of_installments

    class DirectPayerParams < StandardError
      def initialize(error_message)
        @exception_type = "custom"
        super(error_message)
      end
    end

    def initialize(entity, customer_payment_method_id, number_of_installments = 1)
      @entity = entity
      @customer_payment_method_id = customer_payment_method_id
      @number_of_installments = number_of_installments.to_i
    end

    def call
      @response = ::Iugu::Charge.create(direct_pay_params)
      
      if @response.attributes["success"] == true
        @entity.update(
          invoice_id: @response.attributes["invoice_id"],
          invoice_url: @response.attributes["url"],
          invoice_pdf: @response.attributes["pdf"],
          number_of_installments: number_of_installments,
          invoice_pix_qrcode_url: nil,
          invoice_pix_qrcode_text: nil,
        )

        ChargeCheckAndUpdateStatus.new(entity).call

        entity.perform_after_payment_confirmation_actions if @entity.respond_to?(:perform_after_payment_confirmation_actions)
        return true
      else
        return false
      end
    end

    def direct_pay_params
      @direct_pay_params ||= @entity.nova_iugu_charge_params_hash.merge(
        customer_payment_method_id: customer_payment_method_id,
        months: number_of_installments,
        items: build_item_values_considering_number_of_installments
      )
    end

    def build_item_values_considering_number_of_installments
      items = @entity.nova_iugu_charge_params_hash[:items]
      return items if number_of_installments == 1
      
      items.each do |item|
        item[:price_cents] = entity.installment_options.find { |option| option[:count].to_i == number_of_installments }[:total_value]
      end
    end
  end  

  class Charger
    attr_reader :entity, :response, :custom_params

    class ChargerParamsException < StandardError
      def initialize(error_message)
        @exception_type = "custom"
        super(error_message)
      end
    end

    def initialize(entity, custom_params = {})
      @entity = entity
      @custom_params = custom_params
    end

    def call
      validate_params!

      @response = ::Iugu::Charge.create(charge_params)

      entity.update!(
        invoice_id: @response.attributes["invoice_id"],
        invoice_url: @response.attributes["url"].gsub("?bs=true", ""),
        invoice_pdf: @response.attributes["pdf"],
        invoice_status: "pending",
      )
    end

    def validate_params!
      raise ChargerParamsException.new("User email (string) not specified at [:email]") if charge_params[:email].blank?
      raise ChargerParamsException.new("Months (int) not specified at [:months]") if charge_params[:months].blank?
      raise ChargerParamsException.new("Items (array) not specified at [:items]") if charge_params[:items].blank?

      charge_params[:items].each_with_index do |item, index|
        raise ChargerParamsException.new("Property 'description' (string) not specified for item with index #{index} at [:items]. Item trace: #{item.to_s}") if item[:description].blank?
        raise ChargerParamsException.new("Property 'quantity' (string) not specified for item with index #{index} at [:items]. Item trace: #{item.to_s}") if item[:quantity].blank?
        raise ChargerParamsException.new("Property 'price_cents' (string) not specified for item with index #{index} at [:items]. Item trace: #{item.to_s}") if item[:price_cents].blank?
      end

      raise ChargerParamsException.new("Payer not specified at [:payer]") if charge_params[:payer].blank?
      raise ChargerParamsException.new("Property 'name' (string) not specified for object payer at [:payer]. Item trace: #{charge_params[:payer].to_s}") if charge_params[:payer][:name].blank?
      raise ChargerParamsException.new("Property 'name' (string) not specified for object payer at [:payer]. Item trace: #{charge_params[:payer].to_s}") if charge_params[:payer][:name].blank?
    end

    def charge_params
      @charge_params ||= @entity.nova_iugu_charge_params_hash.merge(invoice_id: entity.invoice_id).merge(custom_params)
    end
  end  

  class ChargeCheckAndUpdateStatus
    attr_reader :invoice

    def initialize(entity)
      @entity = entity
    end

    def call
      @entity.check_payment_actions_performed if @entity.respond_to?(:check_payment_actions_performed)
      
      return true unless @entity.invoice_status == "pending"

      begin
        @invoice ||= Iugu::Invoice.fetch(@entity.invoice_id)
      rescue Iugu::ObjectNotFound
        return
      end

      if (@invoice.attributes["status"] == "paid")
        @entity.update(
          invoice_paid_at: @invoice.attributes["paid_at"],
          value: @invoice.attributes["paid_cents"],
          net_value: @invoice.attributes["paid_cents"] - @invoice.attributes["taxes_paid_cents"]
        )
        @entity.perform_after_payment_confirmation_actions if @entity.respond_to?(:perform_after_payment_confirmation_actions)
      end

      @entity.update(invoice_status: @invoice.attributes["status"])
    end
  end
end

# In order for an entity to be chargeable, it needs to contain:

# The attribute fields "invoice_id", "invoice_url", "invoice_status", "invoice_pdf", "invoice_paid_at", "value" and "net_value"

# A method called "nova_iugu_charge_params_hash" with the following body:
# {
#   email: string,
#   months: int,
#   items: [
#     {
#       description: string,
#       quantity: string,
#       price_cents: string
#     },
#   ],
#   payer: {  --> For pix/credit_card, use only payer: {name: ""}
#     name: string,
#     email: string,  --> ONLY NEEDED FOR BANK_SLIP
#     cpf_cnpj: string, --> ONLY NEEDED FOR BANK_SLIP
#     address: {
#       street: string, --> ONLY NEEDED FOR BANK_SLIP
#       number: string, --> ONLY NEEDED FOR BANK_SLIP
#       district: string, --> ONLY NEEDED FOR BANK_SLIP
#       city: string, --> ONLY NEEDED FOR BANK_SLIP
#       state: string (state acronym), --> ONLY NEEDED FOR BANK_SLIP
#       country: "BR", --> ONLY NEEDED FOR BANK_SLIP
#       zip_code: string, --> ONLY NEEDED FOR BANK_SLIP
#     }
#   }
#   return_url: Rails.env.production? ? string(production return url) : string (development return url),
#   ignore_due_email: true,
#   ignore_canceled_email: true,  
#   due_date: (Time.zone.today + x.days),        
# }

# A method perform_after_payment_confirmation_actions of all the actions that have to be performed after payment
# changes to paid

# A method check_payment_actions_performed to check if the payment actions were performed, 
# because if they weren't, they will be performed again (safecheck method)

# Suggested Entity#create action:
# def new
#   @entity = Entity.find(params[:entity_id])
#   authorize @entity, :pay?
#   @order = @entity.order

#   if @order.blank? || @order.invoice_id.blank? || @order.invoice_status == "expired" || @order.invoice_status == "canceled"
#     @order = Order.create(entity: @entity)
#     begin
#       ::NovaIugu::InvoiceGenerator.new(@order).call
#     rescue 
#       @order_error = true
#     end
#   else
#     begin
#       ::NovaIugu::ChargeCheckAndUpdateStatus.new(@order).call
#     rescue Iugu::ObjectNotFound
#       begin
#         ::NovaIugu::InvoiceGenerator.new(@order).call
#       rescue 
#         @order_error = true
#       end
#     end
#   end
# end

# Suggested view:
# <div class="payment-confirmed success-text hide flex center around">
#   <div class="p-5">
#     <h3><i class="fas fa-thumbs-up fs-20 pr-4 mb-4"></i>Pagamento confirmado!</h3>
#     <%= link_to entity_path_for_user(@entity, current_user) do %>
#       <p class="btn btn-success w-100">Prosseguir</p>
#     <% end %>
#   </div>
# </div>
# <div class="payment-container" data-entity-id="<%= @order.entity.id %>">
#   <div class="my-5">
#     <div class="order-waiting-payment warning-text p-5 my-2">
#       <p><i class="fas fa-exclamation-triangle fs-20 pr-4 mb-3"></i>Aguardando pagamento da fatura abaixo...</p>
#       <p>FORMAS DE PAGAMENTO: Você pode pagar por PIX, cartão de crédito ou boleto.</p>
#       <p>PIX: Leia o QR code na fatura abaixo e conclua o operação no seu celular. Aguarde a confirmação do pagamento nessa mesma página.</p>
#       <p>CARTÃO DE CRÉDITO: Insira os dados do cartão nos respectivos campos na fatura abaixo e clique "pagar". Aguarde a confirmação do pagamento nessa mesma página.</p>
#       <p><b>BOLETO: Faça o pagamento do boleto na fatura abaixo. O pagamento leva até 4 dias úteis para ser processado. Você receberá um e-mail após a confirmação, então volte aqui para baixar sua petição.</b></p>
#     </div>
#   </div>

#   <% if @order_error %>
#     <p class="danger-text">
#       <i class="fas fa-exclamation-triangle mr-3 p-5 fs-30"></i>
#       Ocorreu um erro no nosso provedor faturamento. Tente novamente amanhã.
#     </p>
#   <% end %>
# </div>
# <% if @order.invoice_url.present? %>
#   <iframe src="<%=@order.invoice_url %>" class="mb-5 invoice" frameborder="0" style="min-height: 1000px; width: 100%"></iframe>
# <% end %>

# Suggested pooling function
# document.addEventListener("DOMContentLoaded", () => {
#   paymentContainer = document.querySelector(".payment-container")
  
#   if (!paymentContainer) return;

#   const entityId = paymentContainer.dataset.eventid;
#   let stopPolling = false;

#   if (!entityId) return;

#   const poolFunction = async () => {
#     if (stopPolling) return;
#     const url = `/events/${eventId}/status.json`

#     const response = await axios.get(url);
  
#     if (response.data === "finished") {
#       document.querySelector(".payment-confirmed").classList.remove("hide")
#       document.querySelector(".payment-container").classList.add("hide")
#       document.querySelector(".invoice").classList.add("hide")
#       document.body.scrollTop = 0; // For Safari
#       document.documentElement.scrollTop = 0; // For Chrome, Firefox, IE and Opera
#       stopPolling = true;
#     }
#   }

#   poolFunction();

#   setInterval(poolFunction, 4000)
# })

# Suggested pooling controller action
# def status
#   @entity = Entity.find(params[:id])
#   authorize @entity

#   ::NovaIugu::ChargeCheckAndUpdateStatus.new(@entity.order).call

#   render json: @entity.status
# end
