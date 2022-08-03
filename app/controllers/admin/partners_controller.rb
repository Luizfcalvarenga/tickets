module Admin
  class PartnersController < ApplicationController
    def index
      @partners = Partner.all.order(:created_at)
    end
    
    def show
      @partner = Partner.find(params[:id])
    end
    
    def new
      @partner = Partner.new
    end
    
    def create
      @partner = Partner.new(partner_params)

      if @partner.save      
        flash[:notice] = "Parceiro criado com sucesso"
        redirect_to admin_partners_path
      else
        flash[:alert] = "Erro na criação do parceiro"
        render :new
      end
    end
    
    def edit
      @partner = Partner.find_by(slug: params[:id])
    end
    
    def update
      @partner = Partner.find_by(slug: params[:id])
      if @partner.update(partner_params)
        flash[:notice] = "Parceiro atualizado com sucesso"
        redirect_to admin_partners_path
      else
        render :edit
      end
    end

    def toggle_active
      @partner = Partner.find_by(slug: params[:slug])

      if @partner.update(active: !@partner.active)
        flash[:notice] = "Parceiro #{@partner.active ? "ativado" : "desativado"}"
        redirect_to admin_partners_path
      else
        flash[:alert] = "Erro ao alterar parceiro: #{@partner.errors.full_messages}"
      end  
    end
    
    def destroy

    end

    private

    def partner_params
      params.require(:partner).permit(:kind, :name, :cnpj, :contact_phone_1, :contact_phone_2, :contact_email, :cep, :state_id, :city_id, :street_name, :street_number, :neighborhood, :address_complement, :logo, :banner, :slug, :about)
    end
  end

end
