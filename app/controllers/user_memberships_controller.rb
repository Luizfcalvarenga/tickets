class UserMembershipsController < ApplicationController
  def create
    membership = Membership.find(create_user_membership_params[:membership_id])
    user_membership = UserMembership.new(create_user_membership_params)
    
    if user_membership.save 
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

      redirect_to partner_path(user_membership.membership.partner)
    else
      raise
    end
  end

  def destroy
    user_membership = UserMembership.find(params[:id])
    
    if user_membership.destroy
      redirect_to partner_path(user_membership.membership.partner)
    else
      raise
    end
  end

  private

  def create_user_membership_params
    params.require(:user_membership).permit(:membership_id).merge(user: current_user)
  end
end
