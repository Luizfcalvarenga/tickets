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
    
    if user_membership.save && user_membership.iugu_subscription_id.present? 
      identifier = SecureRandom.uuid

      pass = Pass.create(
        identifier: identifier,
        user_membership: user_membership,
        name: membership.name,
        partner_id: membership.partner_id,
        user: current_user,
        qrcode_svg: RQRCode::QRCode.new(identifier).as_svg(
          color: "000",
          shape_rendering: "crispEdges",
          module_size: 5,
          standalone: true,
          use_path: true,
        ),
      )

      DiscordMessager.call("Nova assinatura iniciada: R$ #{number_to_currency(user_membership.membership.price_in_cents.to_f/100, unit: "R$", separator: ",", delimiter: ".")} cobrados a cada #{user_membership.membership.recurrence_interval_in_months} meses")

      flash[:notice] = "Assinatura iniciada com sucesso"

      redirect_to dashboard_path_for_user(current_user)
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
