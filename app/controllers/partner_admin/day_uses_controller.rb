module PartnerAdmin
  class DayUsesController < ApplicationController
    def show
      @day_use = DayUse.find(params[:id])
    end

    def new
      @day_use = DayUse.new
      @weekdays = [
        {value: "monday", label: "Segunda-feira"},
        {value: "tuesday", label: "Terça-feira"},
        {value: "wednesday", label: "Quarta-feira"},
        {value: "thursday", label: "Quinta-feira"},
        {value: "friday", label: "Sexta-feira"},
        {value: "saturday", label: "Sábado"},
        {value: "sunday", label: "Domingo"},
      ]
    end
  
    def create            
      ActiveRecord::Base.transaction do  
        day_use = DayUse.create!(day_use_params)

        day_use_schedule_params.each do |day_use_schedule_param|
          DayUseSchedule.create!(
            weekday: day_use_schedule_param[:weekday],
            name: day_use_schedule_param[:name],
            start_time: day_use_schedule_param[:start_time],
            end_time: day_use_schedule_param[:end_time],
            price_in_cents: day_use_schedule_param[:price_in_cents],
            day_use: day_use,
          )
        end
      end

      flash[:notice] = "Day Use criado com sucesso"
      redirect_to dashboard_path_for_user(current_user)
    end
    
    private

    def day_use_params
      params.require(:day_use).permit(:name, :description, :photo).merge(partner: current_user.partner)
    end

    def day_use_schedule_params
      params.require(:day_use).permit(day_use_schedules: [:weekday, :name, :start_time, :end_time, :price_in_cents])[:day_use_schedules]
    end
  end
end
