class EventMailer < ApplicationMailer
  default from: 'NuflowPass <naoresponda@nuflowpass.com.br>'

  def send_event_communication(user, event_communication)
    @user = user
    @event_communication = event_communication
    @event_communication_url = event_event_communication_url(event_id: @event_communication.event_id, id: @event_communication.id)

    event_communication.files.each do |file|
      attachments[file.filename.to_s] = file.download
    end
    
    mail(to: @user.email, subject: "Comunicado para seu evento #{event_communication.event.name}: #{event_communication.subject}")
  end
end
