module PartnerAdmin
  class DayUseBlocksController < ApplicationController
    def new
      @day_use = DayUse.find(params[:day_use_id])
      @day_use_block = DayUseBlock.new

      @weekday_collection = [
        ["Segunda-feira", "monday"],
        ["Terça-feira", "tuesday"],
        ["Quarta-feira", "wednesday"],
        ["Quinta-feira", "thursday"],
        ["Sexta-feira", "friday"],
        ["Sábado", "saturday"],
        ["Domingo", "sunday"],
        ["Todos os dias", "all"],
      ]
    end
  
    def create
      @day_use_block = DayUseBlock.new(day_use_block_params)
            
      if @day_use_block.save
        flash[:notice] = "Bloqueio criado com sucesso"
        redirect_to partner_admin_day_use_path(@day_use_block.day_use)
      else
        flash[:alert] = "Erro ao criar bloqueio de Agendamento"
        render :new
      end 
    end

    def destroy
      @day_use_block = DayUseBlock.find(params[:id])

      if @day_use_block.destroy
        flash[:notice] = "Bloqueio reomvido com sucesso"
        redirect_to partner_admin_day_use_path(@day_use_block.day_use)
      else
        flash[:alert] = "Erro ao remover bloqueio de Agendamento"
        render :new
      end
    end
    
    private

    def day_use_block_params
      params.require(:day_use_block).permit(:block_date, :weekday, :start_time, :end_time).merge(day_use: DayUse.find(params[:day_use_id]), created_by: current_user)
    end
  end
end