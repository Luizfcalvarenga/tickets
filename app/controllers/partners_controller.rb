
class PartnersController < ApplicationController
  skip_before_action :authenticate_user!, only: :show

  def index
    @partners = Partner.all
  end
  
  def show
    @partner = Partner.find_by(slug: params[:id])

    if @partner.blank?
      flash[:alert] = "Parceiro não encontrado"
      redirect_to root_path and return
    end

    @events = @partner.events
    @day_uses = @partner.day_uses
    @weekdays = [
      {value: "sunday", label: "Domingo", day_uses: @day_uses.open_for_weekday("sunday"), order: 0, date: next_date_for_weekday("sunday")},
      {value: "monday", label: "Segunda-feira", day_uses: @day_uses.open_for_weekday("monday"), order: 1, date: next_date_for_weekday("monday")},
      {value: "tuesday", label: "Terça-feira", day_uses: @day_uses.open_for_weekday("tuesday"), order: 2, date: next_date_for_weekday("tuesday")},
      {value: "wednesday", label: "Quarta-feira", day_uses: @day_uses.open_for_weekday("wednesday"), order: 3, date: next_date_for_weekday("wednesday")},
      {value: "thursday", label: "Quinta-feira", day_uses: @day_uses.open_for_weekday("thursday"), order: 4, date: next_date_for_weekday("thursday")},
      {value: "friday", label: "Sexta-feira", day_uses: @day_uses.open_for_weekday("friday"), order: 5, date: next_date_for_weekday("friday")},
      {value: "saturday", label: "Sábado", day_uses: @day_uses.open_for_weekday("saturday"), order: 6, date: next_date_for_weekday("saturday")},
    ]
    current_weekday_value = Time.current.wday
    @weekdays = @weekdays.select { |wd| wd[:order] >= current_weekday_value } + @weekdays.select { |wd| wd[:order] < current_weekday_value }
    @weekdays[0][:today] = true
    @weekdays[0][:label] += " (Hoje)"

    @memberships = @partner.memberships.where.not(id: current_user.user_memberships.active.ids)

    if current_user.present?
      @passes = current_user.passes.joins(event: :partner).where(partners: {id: @partner.id})
      @user_memberships = current_user.user_memberships.joins(membership: :partner).where(partners: {id: @partner.id})

      @user_membership = UserMembership.new
    end
  end
end
