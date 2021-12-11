class PartnerAdmin::MembershipsController < ApplicationController
  before_action 

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
    @membership.destroy
    if @membership.save
      redirect_to partner_admin_memberships_path
    else
      render :edit
    end
  end

  private

  def membership_params
    params.require(:membership).permit(:id, :name, :short_description, :description, :price, :partner_id)
          .merge(partner: current_user.partner)
  end
end
