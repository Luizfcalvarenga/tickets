module PartnerAdmin
  class EventsController < ApplicationController
    def show
      @event = Event.find(params[:id])
      @users = User.select('distinct(users.id), users.email').joins(qrcodes: :event)
        .joins("left join accesses on accesses.event_id = events.id")
        .where(events: { id: @event.id })
      @accesses = @event.accesses
    end
  end
end
