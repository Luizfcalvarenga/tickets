class EntityQuestion < ApplicationRecord
  belongs_to :question
  belongs_to :event_batch
  belongs_to :day_use
end
