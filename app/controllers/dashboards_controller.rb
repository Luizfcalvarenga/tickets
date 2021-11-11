class DashboardsController < ApplicationController
  def user_dashboard
    @qrcodes = current_user.qrcodes
    @user_memberships = current_user.user_memberships
  end

  def partner_dashboard
    @events = current_user.partner.events
  end

  def partner_admin_dashboard
    @events = current_user.partner.events
  end

  def admin_dashboard

  end
end
