module Api
  module V1
    class DayUsesController < ApplicationController
      skip_before_action :authenticate_user!
      
      def show
        day_use = DayUse.find(params[:id])
        date = Date.parse(params[:date])
        day_use_schedule = day_use.schedule_for_date(date)

        render json: "Erro: Agendamento não encontrado para data" and return if day_use_schedule.blank?

        render json: {
          open_slots_for_date: day_use_schedule.open_slots_for_date(date),
          pass_types: day_use_schedule.day_use_schedule_pass_types.active.order(:name)
        }
      end
    end
  end
end
