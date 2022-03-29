class DashboardsController < ApplicationController
  def user_dashboard
    @passes = current_user.passes.order(:start_time)
    @user_memberships = current_user.user_memberships
    @profile = current_user
  end

  def partner_dashboard
    @events = current_user.partner.events
  end

  def partner_admin_dashboard
    @partner = current_user.partner
    @events = current_user.partner.events
    @day_uses = current_user.partner.day_uses    
    @memberships = @partner.memberships
    
    @users = User.joins(passes: [user_membership: :membership]).where(memberships: {id: @memberships.ids}).group("users.id").order("users.name")
  
    if params[:query].present?
      sql_query = "users.email ILIKE :query OR users.name ILIKE :query OR translate(users.document_number, '.', '') ILIKE :query "
      @users = @users.where(sql_query, query: "%#{params[:query].gsub(".", "")}%") if params[:query].present?
    end      

    qrcode = RQRCode::QRCode.new(partner_shortcut_url(id: current_user.partner.slug))
    @svg = qrcode.as_svg(
      color: "000",
      shape_rendering: "crispEdges",
      module_size: 7,
      standalone: true,
      use_path: true
    )

    respond_to do |format|
      format.html
      format.csv { send_data Partner.memberships_csv }
      format.text { render partial: 'memberships/user_list', locals: { users: @users, passes: @passes }, formats: [:html] }
    end
  end

  def admin_dashboard
    @entities_to_approve = Event.not_approved + DayUse.not_approved + Membership.not_approved
  end
end
