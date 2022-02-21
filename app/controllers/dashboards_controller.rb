class DashboardsController < ApplicationController
  def user_dashboard
    @passes = current_user.passes.order(:start_time)
    @user_memberships = current_user.user_memberships
  end

  def partner_dashboard
    @events = current_user.partner.events
  end

  def partner_admin_dashboard
    @partner = Partner.all
    @events = current_user.partner.events
    @memberships = current_user.partner.memberships
    @day_uses = current_user.partner.day_uses

    qrcode = RQRCode::QRCode.new(partner_shortcut_url(id: current_user.partner.slug))
    @svg = qrcode.as_svg(
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
