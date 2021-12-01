class EventQuestion < ApplicationRecord
  belongs_to :event

  enum kind: {
    multiple_choice: "multiple_choice",
    open: "open",
  }
end
