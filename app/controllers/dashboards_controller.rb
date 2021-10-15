class DashboardsController < ApplicationController
  def user_dashboard
    @qrcodes = current_user.qrcodes
    @events = Event.where.not(id: current_user.events.ids)
    @memberships = Membership.where.not(id: current_user.memberships.ids)
    @user_membership = UserMembership.new
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
