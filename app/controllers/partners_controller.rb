
class PartnersController < ApplicationController
  skip_before_action :authenticate_user!, only: :show

  def index
    @partners = Partner.all
  end
  
  def show
    @partner = Partner.find_by(slug: params[:id])

    if @partner.blank?
      flash[:alert] = "Parceiro não encontrado"
      redirect_to root_path
    end

    if @partner.present?
      @events = @partner.events.where.not(id: current_user&.events&.ids)
      @memberships = @partner.memberships.where.not(id: current_user&.memberships&.ids)
    end

    if current_user.present?
      @passes = current_user.passes.joins(event: :partner).where(partners: {id: @partner.id})
      @user_memberships = current_user.user_memberships.joins(membership: :partner).where(partners: {id: @partner.id})

      @user_membership = UserMembership.new
    end
  end
end
