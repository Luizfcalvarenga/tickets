class PartnerAdmin::MembershipsController < ApplicationController
  before_action 

  def index
    @partner = current_user.partner

    @memberships = @partner.memberships

    @users = User.joins(passes: [user_membership: :membership]).where(memberships: {id: @memberships.ids})
      .group("users.id")
      .order("users.name")
  
    if params[:query].present?
      sql_query = "users.email ILIKE :query OR users.name ILIKE :query OR translate(users.document_number, '.', '') ILIKE :query "
      @users = @users.where(sql_query, query: "%#{params[:query].gsub(".", "")}%") if params[:query].present?
    end      

    respond_to do |format|
      format.html
      format.csv { send_data @partner.memberships_csv }
      format.text { render partial: 'partner_admin/memberships/user_list', locals: { users: @users, passes: @passes }, formats: [:html] }
    end
  end

  def show
    @membership = Membership.find(params[:id])
  end

  def new
    @membership = Membership.new
  end

  def create
    @membership = Membership.new(membership_params)
    if @membership.save
      redirect_to dashboard_path_for_user(current_user)
    else
      render :new
    end
  end

  def edit
    @membership = Membership.find(params[:id])
  end

  def update
    @membership = Membership.find(params[:id])
    @membership.update(membership_params)
    if @membership.save
      redirect_to dashboard_path_for_user(current_user)
    else
      render :edit
    end
  end

  def destroy
    @membership = Membership.find(params[:id])
    begin
      if @membership.destroy
        redirect_to partner_admin_dashboard_path
      else
        flash[:alert] = "Could not delete membership"
        redirect_to  partner_admin_dashboard_path
      end
    rescue StandardError => e
      flash[:alert] = "Cê ta louco, não pode apagar essa membership"
      # flash[:alert] = e
      redirect_to  partner_admin_dashboard_path
    end
  end

  private

  def membership_params
    params.require(:membership).permit(:id, :name, :short_description, :description, :terms_of_use, :price_in_cents, :partner_id)
          .merge(partner: current_user.partner)
  end
end
