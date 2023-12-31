module PartnerAdmin
  class DayUsesController < ApplicationController
    def show
      @day_use = DayUse.find(params[:id])
      @day_use_schedules = @day_use.day_use_schedules.order_by_weekday

      @passes = @day_use.passes.after_date(Time.current).distinct("passes.id")
        .joins(question_answers: :question)
        .joins(:user)
        .order(:start_time)
    
      if params[:query].present?
        sql_query = "question_answers.value ILIKE :query OR users.email ILIKE :query"
        @passes = @passes.where(sql_query, query: "%#{params[:query]}%") if params[:query].present?
      end      

      @passes = @passes.group("passes.id")

      @order = Order.new

      @day_use_blocks = @day_use.day_use_blocks
      @coupons = @day_use.coupons

      respond_to do |format|
        format.html
        format.csv { send_data @day_use.passes_csv }
        format.text { render partial: 'partner_admin/day_uses/user_list', locals: { day_use: @day_use, passes: @passes }, formats: [:html] }
      end
    end

    def new
      @day_use = DayUse.new
      @day_use_schedules = @day_use.day_use_schedules
    end
  
    def create
      service = DayUseCreator.new(params, current_user)
      
      if service.call
        flash[:notice] = "Agendamento criado com sucesso"
        redirect_to dashboard_path_for_user(current_user)
      else
        @day_use = service.day_use
        @day_use_schedules = @day_use.day_use_schedules
        @restore_params_after_error = true
        @errors = service.errors
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
        flash[:notice] = "Agendamento atualizado com sucesso"
        redirect_to dashboard_path_for_user(current_user)
      else
        flash[:alert] = "Erro ao atualizar Agendamento"
        @day_use = service.day_use
        @day_use_schedules = @day_use.day_use_schedules
        @restore_params_after_error = true
        @errors = service.errors
        render :edit
      end 
    end

    def toggle_activity
      @day_use = DayUse.find(params[:id])

      if @day_use.update(deactivated_at: @day_use.deactivated_at.present? ? nil : Time.current)
        flash[:notice] = "Agendamento #{@day_use.deactivated_at.present? ? "desativado" : "ativado"}"
        redirect_to dashboard_path_for_user(current_user)
      else
        flash[:alert] = "Erro ao alterar agendamento"
      end  
    end
    
    private

    def day_use_params
      params.require(:day_use).permit(:name, :description, :photo, :terms_of_use).merge(partner: current_user.partner)
    end

    def day_use_schedule_params
      params.require(:day_use).permit(day_use_schedules: [:weekday, :name, :description, :photo, :opens_at, :closes_at, :price_in_cents, :quantity_per_slot, :slot_duration_in_minutes, pass_types: [:id, :name, :price_in_cents]])[:day_use_schedules]
    end
  end
end
