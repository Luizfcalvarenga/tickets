class EventQuestionQrcodeAnswer < ApplicationRecord
  belongs_to :event_question
  belongs_to :qrcode
end
