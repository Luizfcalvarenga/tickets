require "iugu"

module NovaIugu
  ::Iugu.api_key = ENV["IUGU_API_KEY"]

  class InvoiceGenerator
    attr_reader :entity, :payable_with

    def initialize(entity, payable_with)
      @entity = entity
      @payable_with = payable_with
    end

    def call
      @response = ::Iugu::Invoice.create(charge_params)
      
      @entity.update!(
        invoice_id: @response.attributes["id"],
        invoice_url: @response.attributes["secure_url"],
        invoice_pdf: "#{@response.attributes["secure_url"]}.pdf",
        invoice_status: @response.attributes["status"],
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
      @charge_params ||= @entity.nova_iugu_charge_params_hash.merge(payable_with: payable_with)
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

      begin
        discord_message_content = "Nova fatura gerada!\nUsuário: #{@entity.event.considered_profile.full_name}\n"
        DiscordMessager.new.call(discord_message_content) if Rails.env.production?
      rescue
      end
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
      @charge_params ||= @entity.nova_iugu_charge_params_hash.merge(custom_params).merge(method: "bank_slip")
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
#       ::NovaIugu::InvoiceGenerator.new(@order, ["pix", "credit_card"]).call
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
#       <p class="btn btn-primary w-100">Prosseguir</p>
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