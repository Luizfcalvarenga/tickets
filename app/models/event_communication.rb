class EventCommunication < ApplicationRecord
  belongs_to :event

  has_many_attached :files

  after_create :send_emails

  def send_emails
    users = User.joins(passes: :event_batch).where(event_batches: {event_id: event.id})
    users.each do |user|
      EventCommunicationMailer.send_event_communication(user, self).deliver_now
    end
  end
end
