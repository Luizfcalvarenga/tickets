class EventBatchQuestion < ApplicationRecord
  belongs_to :question
  belongs_to :event_batch
end
