class DashboardsController < ApplicationController
  def user_dashboard
    @passes = current_user.passes
    @user_memberships = current_user.user_memberships
  end

  def partner_dashboard
    @events = current_user.partner.events
  end

  def partner_admin_dashboard
    @partner = Partner.all
    @events = current_user.partner.events
    @memberships = Membership.where(partner_id: current_user.partner.id)

    # qrcode = RQRCode::QRCode.new(url_for controller: 'partners', action: 'show', host: 'bike-park.herokuapp.com', id: current_user.partner.id)
    pass = RQRCode::QRCode.new(partner_shortcut_url(id: current_user.partner.slug))
    @svg = pass.as_svg(
      color: "000",
      shape_rendering: "crispEdges",
      module_size: 7,
      standalone: true,
      use_path: true
    )
  end

  def admin_dashboard

  end
end
