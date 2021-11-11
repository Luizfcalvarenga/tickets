
class PartnersController < ApplicationController
  def index
    @partners = Partner.all
  end
  
  def show
    @partner = Partner.find(params[:id])
  end
  
  def new
    @partner = Partner.new
  end
  
  def create
    @partner = Partner.new(partner_params)

    if User.exists?(email: params[:partner][:main_contact_email])
      flash[:alert] = "O contato principal já existe"
      render :new and return
    end

    if @partner.save
      main_partner = User.create(email: params[:partner][:main_contact_email], password: "123456")
      @partner.update(main_partner: main_partner)
    else
      flash[:alert] = "Erro na criação do parceiro"
      render :new
    end
  end
  
  def edit

  end
  
  def update

  end
  
  def destroy

  end

  private

  def partner_params
    params.require(:partner).permit(:name, :cnpj, :contact_phone_1, :contact_phone_2, :contact_email, :cep, :state_id, :city_id, :street_name, :street_number, :neighborhood, :address_complement)
  end
end
