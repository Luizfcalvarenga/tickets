class EventCommunication < ApplicationRecord
  belongs_to :event

  has_many_attached :files

  after_create :send_emails

  def send_emails
    users = User.joins(passes: :event_batch).where(event_batches: {event_id: event.id})
    users.each do |user|
      EventMailer.send_event_communication(user, self).deliver_later
    end
  end
end
