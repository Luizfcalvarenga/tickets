class EventQuestionBatch < ApplicationRecord
  belongs_to :event_question
  belongs_to :event_batch
end
