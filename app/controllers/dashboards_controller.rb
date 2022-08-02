class DashboardsController < ApplicationController
  def user_dashboard
    @passes = current_user.passes.where("day_use_schedule_pass_type_id IS NOT NULL or event_batch_id IS NOT NULL").order(start_time: :desc).active
    @membership_passes = current_user.passes.where("user_membership_id IS NOT NULL").active
    @orders = current_user.orders.order(created_at: :desc)
    @profile = current_user
  end

  def partner_dashboard
    @events = current_user.partner.events
  end

  def partner_user_dashboard
    @partner = current_user.partner
    @events = current_user.partner.events.active
    @day_uses = current_user.partner.day_uses.active
    @memberships = (@partner.memberships.active + @partner.memberships.joins(:user_memberships).merge(UserMembership.active)).uniq
    
    @users = User.joins(passes: [user_membership: :membership]).where(memberships: {id: @memberships.map(&:id)}).group("users.id").order("users.name")

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
    @events = current_user.partner.events.order(scheduled_start: :desc).active
    @day_uses = current_user.partner.day_uses.active
    @memberships = (@partner.memberships.active + @partner.memberships.joins(:user_memberships).merge(UserMembership.active)).uniq
    
    @users = User.joins(passes: [user_membership: :membership]).where(memberships: {id: @memberships.map(&:id)}).group("users.id").order("users.name")

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
    entities = [Event.order(scheduled_start: :desc), DayUse.order(created_at: :desc), Membership.order(created_at: :desc)]
    entities.map! { |entity_collection| entity_collection.where(partner_id: params[:admin_dashboard][:partner_id])} if params[:admin_dashboard].present? && params[:admin_dashboard][:partner_id].present?
    @collections = [:active, :not_approved, :deactivated].map do |scope|
      entities.map { |entity| entity.send(scope) }.reduce(:+)
    end

    @events_with_group_buy = Event.where.not(group_buy_code: nil)
  end
end
