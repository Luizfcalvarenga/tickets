module PartnerAdmin
  class DayUsePackagesController < ApplicationController
    def new
      @day_use = DayUse.find(params[:day_use_id])
      @day_use_package = DayUsePackage.new
    end
  
    def create
      @day_use_package = DayUsePackage.new(day_use_package_params)
            
      if @day_use_package.save
        flash[:notice] = "Pacote criado com sucesso"
        redirect_to partner_admin_day_use_path(@day_use_package.day_use)
      else
        @day_use = DayUse.find(params[:day_use_id])
        flash[:alert] = "Erro ao criar pacote"
        render :new
      end 
    end

    def edit
      @day_use = DayUse.find(params[:day_use_id])
      @day_use_package = DayUsePackage.find(params[:id])
    end
  
    def update
      @day_use_package = DayUsePackage.find(params[:id])
            
      if @day_use_package.update(day_use_package_params)
        flash[:notice] = "Pacote atualizado com sucesso"
        redirect_to partner_admin_day_use_path(@day_use_package.day_use)
      else
        @day_use = DayUse.find(params[:day_use_id])
        flash[:alert] = "Erro ao atualizar pacote"
        render :new
      end 
    end

    def destroy
      @day_use_package = DayUsePackage.find(params[:id])

      if @day_use_package.update(deactivated_at: Time.current)
        flash[:notice] = "Pacote removido com sucesso"
        redirect_to partner_admin_day_use_path(@day_use_package.day_use)
      else
        flash[:alert] = "Erro ao remover pacote de agendamentos"
        render :new
      end
    end
    
    private

    def day_use_package_params
      params.require(:day_use_package).permit(:description, :quantity_of_passes, :kind, :discount, day_use_schedule_pass_type_ids: []).merge(day_use: DayUse.find(params[:day_use_id]), created_by: current_user)
    end
  end
end
