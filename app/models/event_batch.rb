class EventBatch < ApplicationRecord
  belongs_to :event

  validates :price_in_cents, :quantity, :name, presence: true

  has_many :passes

  scope :not_ended, -> { where(ended_at: nil) }
end
