module PartnerAdmin
  class DayUsesController < ApplicationController
    def show
      @day_use = DayUse.find(params[:id])
      @day_use_schedules = @day_use.day_use_schedules.sort_by { |dus| next_date_for_weekday(dus.weekday) }

      date = params[:date].present? ? Date.new(*params[:date].split("-").reverse.map(&:to_i)) : Time.current  

      @passes = @day_use.passes.for_date(date)
        .distinct("passes.id")
        # .joins(question_answers: :question)
        # .where(question: { prompt: ["Nome completo"] })
        # .order("question_answers.value")
    
      # if params[:query].present?
      #   sql_query = "question_answers.value ILIKE :query"
      #   @passes = @passes.where(sql_query, query: "%#{params[:query]}%") if params[:query].present?
      # end      

      # @passes = @passes.group("passes.id").order("MAX(question_answers.value) DESC")

      respond_to do |format|
        format.html
        format.csv { send_data @day_use.passes_csv }
        format.text { render partial: 'partner_admin/day_uses/user_list', locals: { day_use: @day_use, passes: @passes }, formats: [:html] }
      end
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
        day_use.create_default_questions

        day_use_schedule_params.each do |day_use_schedule_param|
          DayUseSchedule.create!(
            weekday: day_use_schedule_param[:weekday],
            name: day_use_schedule_param[:name],
            opens_at: day_use_schedule_param[:opens_at],
            closes_at: day_use_schedule_param[:closes_at],
            price_in_cents: day_use_schedule_param[:price_in_cents],
            quantity_per_slot: day_use_schedule_param[:quantity_per_slot],
            slot_duration_in_minutes: day_use_schedule_param[:slot_duration_in_minutes],
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
      params.require(:day_use).permit(day_use_schedules: [:weekday, :name, :opens_at, :closes_at, :price_in_cents, :quantity_per_slot, :slot_duration_in_minutes])[:day_use_schedules]
    end
  end
end
