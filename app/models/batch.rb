class Batch < ApplicationRecord
  belongs_to :event

  validates :price, :quantity, :name, presence: true

  has_many :passes

  scope :not_ended, -> { where(ended_at: nil) }
end
