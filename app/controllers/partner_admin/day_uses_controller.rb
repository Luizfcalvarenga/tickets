module PartnerAdmin
  class DayUsesController < ApplicationController
    def show
      @day_use = DayUse.find(params[:id])
      @day_use_schedules = @day_use.day_use_schedules.sort_by { |dus| next_date_for_weekday(dus.weekday) }

      date = params[:date].present? ? Date.new(*params[:date].split("-").reverse.map(&:to_i)) : Time.current  

      @passes = @day_use.passes.for_date(date).distinct("passes.id")
        .joins(question_answers: :question)
        .joins(:user)
        # .where(question: { prompt: ["Nome completo"] })
        # .order("question_answers.value")
    
      if params[:query].present?
        sql_query = "question_answers.value ILIKE :query OR users.ema   il ILIKE :query"
        @passes = @passes.where(sql_query, query: "%#{params[:query]}%") if params[:query].present?
      end      

      @passes = @passes.group("passes.id")

      @order = Order.new

      @day_use_blocks = @day_use.day_use_blocks

      respond_to do |format|
        format.html
        format.csv { send_data @day_use.passes_csv }
        format.text { render partial: 'partner_admin/day_uses/user_list', locals: { day_use: @day_use, passes: @passes }, formats: [:html] }
      end
    end

    def new
      @day_use = DayUse.new
    end
  
    def create
      @day_use = DayUse.new 
      
      service = DayUseCreator.new(params, current_user)
      
      if service.call
        flash[:notice] = "Day use criado com sucesso"
        redirect_to dashboard_path_for_user(current_user)
      else
        flash[:alert] = "Erro ao criar Day Use"
        render :new
      end 
    end

    def edit
      @day_use = DayUse.find(params[:id])
      @day_use_schedules = @day_use.day_use_schedules
    end

    def update
      @day_use = DayUse.find(params[:id])

      service = DayUseUpdater.new(@day_use, params)
      
      if service.call
        flash[:notice] = "Day use atualizado com sucesso"
        redirect_to dashboard_path_for_user(current_user)
      else
        flash[:alert] = "Erro ao atualizar Day Use"
        render :new
      end 

    end
    
    private

    def day_use_params
      params.require(:day_use).permit(:name, :description, :photo).merge(partner: current_user.partner)
    end

    def day_use_schedule_params
      params.require(:day_use).permit(day_use_schedules: [:weekday, :name, :opens_at, :closes_at, :price_in_cents, :quantity_per_slot, :slot_duration_in_minutes, pass_types: [:id, :name, :price_in_cents]])[:day_use_schedules]
    end
  end
end
