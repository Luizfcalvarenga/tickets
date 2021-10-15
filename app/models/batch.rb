class Batch < ApplicationRecord
  belongs_to :event

  validates :price, :quantity, :name, presence: true

  has_many :qrcodes

  scope :not_ended, -> { where(ended_at: nil) }
end
