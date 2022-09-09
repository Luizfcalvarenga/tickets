module PartnerAdmin
  class EventsController < ApplicationController
    def show
      @event = Event.find(params[:id])
      @passes = @event.passes
        .joins(question_answers: :question)
        .joins(:user)
        .distinct("passes.id")
    
      if params[:query].present?
        sql_query = "question_answers.value ILIKE :query OR users.email ILIKE :query"
        @passes = @passes.where(sql_query, query: "%#{params[:query]}%") if params[:query].present?
      end

      @total_passes_count = @passes.count
      @access_count = @passes.joins(:accesses).uniq.count

      @passes = @passes.limit(50).offset((params[:page] || 0).to_i * 50 )    

      @order = Order.new

      @max_pages = (@total_passes_count / 50).ceil

      respond_to do |format|
        format.html
        format.csv { send_data @event.passes_csv, filename: "Controle de acessos - #{@event.name}.csv" }
        format.text { render partial: 'partner_admin/events/user_list', locals: { event: @event, passes: @passes }, formats: [:html] }
      end
    end

    def new
      @event = Event.new
      @states = State.all
      @cities = @event.state.present? ? @event.state.cities : []
      @experiences = current_user.partner.events.pluck(:experience).select(&:present?).uniq
      @errors = {}
    end
  
    def create
      service = EventCreator.new(params, current_user)
      
      if service.call
        flash[:notice] = "Evento criado com sucesso"
        redirect_to dashboard_path_for_user(current_user)
      else
        flash[:alert] = "Erro ao criar evento"
        @event = service.event
        @states = State.all
        @cities = @event.state.present? ? @event.state.cities : []
        @experiences = current_user.partner.events.pluck(:experience).select(&:present?).uniq
        @errors = service.errors
        @restore_params_after_error = true
        render :new
      end     
    end

    def edit
      @event = Event.find(params[:id])
      @states = State.all
      @cities = @event.state.present? ? @event.state.cities : []
      @experiences = @event.partner.events.pluck(:experience).select(&:present?).uniq
      @errors = {}
    end

    def update
      @event = Event.find(params[:id])
      @states = State.all
      @cities = @event.state.present? ? @event.state.cities : []
      @experiences = @event.partner.events.pluck(:experience).select(&:present?).uniq

      service = EventUpdater.new(@event, params)
      
      if service.call
        flash[:notice] = "Evento atualizado com sucesso"
        redirect_to dashboard_path_for_user(current_user)
      else
        flash[:alert] = "Erro ao atualizar evento"
        @errors = service.errors
        @restore_params_after_error = true
        render :edit
      end  
    end

    def toggle_activity
      @event = Event.find(params[:id])

      if @event.update(deactivated_at: @event.deactivated_at.present? ? nil : Time.current)
        flash[:notice] = "Evento #{@event.deactivated_at.present? ? "desativado" : "ativado"}"
        redirect_to dashboard_path_for_user(current_user)
      else
        flash[:alert] = "Erro ao alterar evento"
      end  
    end

    def delete_attachments
      @event = Event.find(params[:id])

      key = params[:key]
      if key == "presentation"
        @event.presentation.purge if @event.presentation.attached?
      elsif key == "sponsors_photos"
        @event.sponsors_photos.each(&:purge) if @event.sponsors_photos.attached?
      elsif key == "supporters_photos"
        @event.supporters_photos.each(&:purge) if @event.supporters_photos.attached?
      end

      flash[:notice] = "Arquivos apagados"
      redirect_to dashboard_path_for_user(current_user)
    end

    def delete_group
      @event = Event.find(params[:id])

      if !@event.group_buy || @event.group_buy_code.blank?
        flash[:alert] = "Esse evento não possui um grupo ativo"
        redirect_to dashboard_path_for_user(current_user) and return
      end
      
      original_pass = @event.passes.order(:created_at).find_by(group_buy_code: @event.group_buy_code)

      ActiveRecord::Base.transaction do 
        original_pass.touch(:deactivated_at)
        @event.update!(group_buy_code: nil)
      end

      flash[:notice] = "Grupo desfeito"
      redirect_to  edit_partner_admin_event_path(@event)
    end

    def clone
      @event = Event.find(params[:id])

      service = EventCloner.new(@event, current_user)
      if service.call
        flash[:notice] = "Evento clonado com sucesso"
        redirect_to  edit_partner_admin_event_path(service.event)
      else
        flash[:alert] = "Erro ao clonar evento: #{service.errors}"
        redirect_to dashboard_path_for_user(current_user)
      end
    end
  end
end
