
class PartnersController < ApplicationController
  def index
    @partners = Partner.all
  end
  
  def show
    @partner = Partner.find_by!(slug: params[:id])

    @events = @partner.events.where.not(id: current_user.events.ids)
    @memberships = @partner.memberships.where.not(id: current_user.memberships.ids)

    @qrcodes = current_user.qrcodes.joins(event: :partner).where(partners: {id: @partner.id})
    @user_memberships = current_user.user_memberships.joins(membership: :partner).where(partners: {id: @partner.id})


    @user_membership = UserMembership.new
  end
end
