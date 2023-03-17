class UserMembershipsController < ApplicationController
  def create
    membership = Membership.find(create_user_membership_params[:membership_id])
    user_membership = UserMembership.new(create_user_membership_params)

    if !current_user.has_completed_profile?
      flash[:notice] = "Por favor, preecha as informações abaixo para prosseguir:"

      redirect_to dashboard_path_for_user(current_user, current_tab: "nav-acc-info", return_url: request.referrer) and return
    end

    if !current_user.has_payment_method?
      flash[:notice] = "Cadastre um método de pagamento para prosseguir:"

      redirect_to payment_methods_path(return_url: request.referrer) and return
    end

    if current_user.has_membership?(membership)
      flash[:notice] = "Você já está inscrito nessa assinatura"
      redirect_to dashboard_path_for_user(current_user) and return
    end

    current_user.create_customer_at_iugu if current_user.iugu_customer_id.blank?

    if user_membership.save
      if user_membership.create_plan_at_iugu
        user_membership.generate_pass
        
        flash[:notice] = "Assinatura iniciada com sucesso"

        redirect_to dashboard_path_for_user(current_user)
      else
        user_membership.destroy

        flash[:alert] = "Erro ao iniciar assinatura. Verifique seu cartão cadastrado."

        redirect_to membership_path(user_membership.membership)
      end
    else
      flash[:alert] = "Erro ao iniciar assinatura. Verifique seu cartão cadastrado."

      redirect_to membership_path(user_membership.membership)
    end
  end

  def destroy
    user_membership = UserMembership.find(params[:id])
    
    if user_membership.update(deactivated_at: Time.current)
      user_membership.passes.update_all(deactivated_at: Time.current)

      response = Iugu::Subscription.fetch(user_membership.iugu_subscription_id).suspend

      flash[:notice] = "Você cancelou sua assinatura em #{user_membership.membership.name}"

      redirect_to dashboard_path_for_user(current_user)
    else
      raise
    end
  end

  private

  def create_user_membership_params
    params.require(:user_membership).permit(:membership_id).merge(user: current_user)
  end
end