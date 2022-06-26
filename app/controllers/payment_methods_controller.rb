class PaymentMethodsController < ApplicationController
  def index
    if !current_user.has_completed_profile?
      flash[:notice] = "Por favor, preecha as informações abaixo para prosseguir:"
      
      redirect_to dashboard_path_for_user(current_user, return_url: request.referrer) and return
    end
    
    NovaIugu::CustomerCreator.new(current_user).call if current_user.iugu_customer_id.blank?
    
    @payment_methods = Iugu::PaymentMethod.fetch({customer_id: current_user.iugu_customer_id}).results
  end

  def create
    response = Iugu::PaymentMethod.create({
      customer_id: current_user.iugu_customer_id,
      description: "Cartão de crédito",
      token: params[:token],
      set_as_default: true,
    })

    if response.errors.blank?
      flash[:notice] = "Cartão adicionado com sucesso"
    else
      flash[:alert] = "Erro ao adicionar cartão: #{response.errors.to_s}"
    end

    redirect_to_return_url_if_one_is_provided and return

    redirect_to payment_methods_path
  end

  def destroy
    response = Iugu::PaymentMethod.new({
      customer_id: current_user.iugu_customer_id,
      id: params[:id]
    }).delete

    flash[:notice] = "Cartão removido com sucesso"
    redirect_to payment_methods_path
  end
end
