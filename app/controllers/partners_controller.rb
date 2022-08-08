class PartnersController < ApplicationController
  NUMBER_OF_DAYS_FORWARD_TO_SHOW_DAY_USES = 10
  
  skip_before_action :authenticate_user!, only: [:index, :show]

  def index
    @partners = Partner.bike_park.active.order(:created_at)
  end
  
  def show
    @partner = Partner.find_by(slug: params[:id])

    if @partner.blank?
      flash[:alert] = "Parceiro não encontrado"
      redirect_to root_path and return
    end

    @events = @partner.events.active
    @day_uses = @partner.day_uses.active
    @memberships = @partner.memberships.active

    if current_user.present?
      @passes = current_user.passes.joins(event: :partner).where(partners: {id: @partner.id})
      @user_memberships = current_user.user_memberships.joins(membership: :partner).where(partners: {id: @partner.id})

      @user_membership = UserMembership.new
    end
  end
end
