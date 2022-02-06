class QuestionAnswer < ApplicationRecord
  belongs_to :event_question
  belongs_to :pass
end
