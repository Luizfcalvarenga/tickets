class DashboardsController < ApplicationController
  def user_dashboard
    @passes = current_user.passes.order(:start_time).active
    @user_memberships = current_user.user_memberships
    @profile = current_user
  end

  def partner_dashboard
    @events = current_user.partner.events
  end

  def partner_user_dashboard
    @partner = current_user.partner
    @events = current_user.partner.events
    @day_uses = current_user.partner.day_uses    
    @memberships = @partner.memberships
    
    @users = User.joins(passes: [user_membership: :membership]).where(memberships: {id: @memberships.ids}).group("users.id").order("users.name")
  
    if params[:query].present?
      sql_query = "users.email ILIKE :query OR users.name ILIKE :query OR translate(users.document_number, '.', '') ILIKE :query "
      @users = @users.where(sql_query, query: "%#{params[:query].gsub(".", "")}%") if params[:query].present?
    end
    
    respond_to do |format|
      format.html
      format.csv { send_data Partner.memberships_csv }
      format.text { render partial: 'memberships/user_list', locals: { users: @users, passes: @passes }, formats: [:html] }
    end
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
    entities = [Event.order(:scheduled_start), DayUse.order(:created_at), Membership.order(:created_at)]
    entities.map! { |entity_collection| entity_collection.where(partner_id: params[:admin_dashboard][:partner_id])} if params[:admin_dashboard].present? && params[:admin_dashboard][:partner_id].present?
    @collections = [:active, :not_approved, :deactivated].map do |scope|
      entities.map { |entity| entity.send(scope) }.reduce(:+)
    end

    @events_with_group_buy = Event.where.not(group_buy_code: nil)
  end
end
