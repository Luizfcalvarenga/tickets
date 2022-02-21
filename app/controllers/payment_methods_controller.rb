class PaymentMethodsController < ApplicationController
  def index
    @payment_methods = Iugu::PaymentMethod.fetch({customer_id: current_user.iugu_customer_id}).results
  end

  def create
    response = Iugu::PaymentMethod.create({
      customer_id: current_user.iugu_customer_id,
      description: "Cartão de crédito galo",
      token: params[:token],
      set_as_default: true,
    })

    flash[:notice] = "Cartão adicionado com sucesso"
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
