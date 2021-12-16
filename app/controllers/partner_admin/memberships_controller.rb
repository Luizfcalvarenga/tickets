class PartnerAdmin::MembershipsController < ApplicationController
  before_action 

  def index
    @memberships = Membership.where(partner_id: current_user.partner.id)
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
      redirect_to partner_admin_membership_path(@membership)
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
      redirect_to partner_admin_membership_path(@membership)
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
    params.require(:membership).permit(:id, :name, :short_description, :description, :price, :partner_id)
          .merge(partner: current_user.partner)
  end
end
