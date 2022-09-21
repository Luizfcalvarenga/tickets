
class OrdersController < ApplicationController
  before_action :authenticate_user!
  
  def show
    @order = Order.find(params[:id])

    if @order.is_free?
      @order.perform_after_payment_confirmation_actions
      flash[:notice] = "Passes retirados com sucesso"
      redirect_to dashboard_path_for_user(current_user) and return
    end
    
    if @order.should_generate_new_invoice?
      ::NovaIugu::InvoiceGenerator.new(@order).call
    else
      begin
        ::NovaIugu::ChargeCheckAndUpdateStatus.new(@order).call
      rescue Iugu::ObjectNotFound
        begin
          ::NovaIugu::InvoiceGenerator.new(@order).call
        rescue 
          raise
        end
      end
    end

    NovaIugu::CustomerCreator.new(current_user).call if current_user.iugu_customer_id.blank?
    
    @payment_methods = Iugu::PaymentMethod.fetch({customer_id: current_user.iugu_customer_id}).results
    @iugu_customer_id = current_user.iugu_customer_id
  end

  def restore
    @order_item_params = params[:order_restore_params]
  end
  
  def create
    if params[:order].blank? || order_items_params.map { |order_item_params| order_item_params["quantity"].to_i }.sum.zero?
      flash[:alert] = "Você não selecionou nenhum ingresso"
      redirect_to "#{request.referrer}?coupon_code=#{params[:coupon_code]}" and return
    end

    if !current_user.has_completed_profile?
      # session[:restore_order] = order_items_params
      flash[:notice] = "Por favor, preecha as informações abaixo para prosseguir:"
      redirect_to dashboard_path_for_user(current_user, current_tab: "nav-acc-info", return_url: request.referrer) and return
    end

    @order = Order.create(user: current_user)

    OrderProcessor.new(@order, order_items_params, params[:coupon_code]).call
    
    if @order.should_generate_new_invoice?
      ::NovaIugu::InvoiceGenerator.new(@order).call
    else
      begin
        ::NovaIugu::ChargeCheckAndUpdateStatus.new(@order).call
      rescue Iugu::ObjectNotFound
        begin
          ::NovaIugu::InvoiceGenerator.new(@order).call
        rescue 
          raise
        end
      end
    end

    if @order.related_entity.class == DayUse
      @order.order_items.each do |order_item|
        @order.related_entity.questions.default.each do |question|
          question.create_answer_for_order_item_based_on_user_account(order_item)
        end
      end

      redirect_to order_path(@order) and return
    end

    redirect_to new_order_question_answer_path(order_id: @order.id) and return
  end

  def pay_with_card
    order = Order.find(params[:id])
    
    customer_payment_method_id = params[:customer_payment_method_id]

    delete_card_after_payment = false

    if customer_payment_method_id.blank? && params[:token].present?
      response = Iugu::PaymentMethod.create({
        customer_id: current_user.iugu_customer_id,
        description: "Cartão de crédito",
        token: params[:token],
        set_as_default: true,
      })

      if response.errors.present?
        DiscordMessager.call("Erro ao realizar pagamento: #{response.errors.inspect}")
        flash[:alert] = "Erro ao realizar pagamento"
        redirect_to request.referrer and return
      end

      customer_payment_method_id = response.attributes["id"]
      delete_card_after_payment = true if params[:save_card] != "on"
    end

    service = NovaIugu::DirectPayer.new(order, customer_payment_method_id, params[:number_of_installments]&.to_i)

    if service.call
      flash[:notice] = "Aguarde nessa tela a confirmação do pagamento"
    else
      flash[:alert] = "Erro ao realizar pagamento"
    end

    if delete_card_after_payment
      Iugu::PaymentMethod.new({
        customer_id: current_user.iugu_customer_id,
        id: customer_payment_method_id
      }).delete
    end

    redirect_to order_path(order)
  end

  def status
    @order = Order.find(params[:id])

    ::NovaIugu::ChargeCheckAndUpdateStatus.new(@order).call

    button_url = user_dashboard_path

    if @order.status == "paid" && @order.passes.count == 1
      button_url = pass_url(@order.passes.first)
    end

    render json: { status: @order.status, button_url: button_url }
  end

  private

  def order_items_params
    params.require(:order).permit(order_items: [:event_batch_id, :day_use_schedule_pass_type_id, :quantity, :price_in_cents, :start_time, :end_time])[:order_items]
  end
end
