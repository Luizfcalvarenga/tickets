class EventCommunicationMailer < ApplicationMailer
  default from: 'NuflowPass <naoresponda@nuflowpass.com.br>'

  def send_event_communication(user, event_communication)
    @user = user
    @event_communication = event_communication
    mail(to: @user.email, subject: event_communication.subject)
  end
end
