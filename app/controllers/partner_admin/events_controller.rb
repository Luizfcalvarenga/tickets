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

      @order = Order.new

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
    end
  
    def create
      service = EventCreator.new(params, current_user)
      
      if service.call
        flash[:notice] = "Evento criado com sucesso"
        redirect_to dashboard_path_for_user(current_user)
      else
        flash[:alert] = "Erro ao criar evento"
        @event = service.event
        render :new
      end     
    end

    def edit
      @event = Event.find(params[:id])
      @states = State.all
      @cities = @event.state.present? ? @event.state.cities : []
    end

    def update
      @event = Event.find(params[:id])
      @states = State.all
      @cities = @event.state.present? ? @event.state.cities : []

      service = EventUpdater.new(@event, params)
      
      if service.call
        flash[:notice] = "Evento atualizado com sucesso"
        redirect_to dashboard_path_for_user(current_user)
      else
        flash[:alert] = "Erro ao atualizar evento"
        render :edit
      end  
    end
    
    private

    def event_params
      params.require(:event).permit(:name, :description, :photo, :scheduled_start, :scheduled_end, :state_id, :city_id, :street_name, :street_number, :street_complement, :neighborhood, :cep, :address_complement)
        .merge(created_by: current_user, partner: current_user.partner)
    end
  
    def create_batch_params
      params.require(:event).permit(event_batches: [:order, :pass_type, :name, :price_in_cents, :quantity, :ends_at])[:event_batches]
    end
  
    def questions_params
      params[:questions] || []
    end
  end
end
