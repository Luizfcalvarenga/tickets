
class EventCommunicationsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show]

  def index
    @event = Event.find(params[:event_id])
    @event_communications = @event.event_communications
  end

  def show
    @event_communication = EventCommunication.find(params[:id])
  end

  def new
    @event = Event.find(params[:event_id])
    @event_communication = EventCommunication.new
  end

  def create
    @event = Event.find(params[:event_id])

    @event_communication = EventCommunication.new(event_communication_params)

    if @event_communication.save
      flash[:notice] = "Comunicado disparado com sucesso"
      redirect_to event_event_communications_path(event_id: @event.id)
    else
      raise
      render :new
    end
  end

  def event_communication_params
    params.require(:event_communication).permit(:subject, :content, files: []).merge(event: @event)
  end
end
