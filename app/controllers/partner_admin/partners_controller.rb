class PartnerAdmin::PartnersController < ApplicationController

  def edit
    @partner = Partner.find_by(slug: params[:id])
  end

  def update
    @partner = Partner.find_by(slug: params[:id])
    if @partner.update(partner_params)
      redirect_to dashboard_path_for_user(current_user)
    else
      render :edit
    end
  end

  private

  def partner_params
    params.require(:partner).permit(:kind, :name, :cnpj, :contact_phone_1, :contact_phone_2, :contact_email, :cep, :state_id, :city_id, :street_name, :street_number, :neighborhood, :address_complement, :logo, :banner, :slug, :about)
  end
end
