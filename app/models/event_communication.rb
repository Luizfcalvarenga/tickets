class EventCommunication < ApplicationRecord
  belongs_to :event

  has_many_attached :files
end
