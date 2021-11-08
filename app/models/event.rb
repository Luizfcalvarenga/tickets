class Event < ApplicationRecord
  belongs_to :partner
  belongs_to :created_by, class_name: "User"
  belongs_to :city
  belongs_to :state

  has_one_attached :photo
  has_many :batches, dependent: :destroy
  has_many :accesses

  has_many :accesses
  has_many :membership_events
  has_many :memberships, through: :membership_events

  has_rich_text :description

  scope :upcoming, -> { where("scheduled_end < ?", Time.current) }
  scope :happening_now, -> { where("scheduled_start > ? and scheduled_end < ?", Time.current, Time.current) }
  scope :past, -> { where("scheduled_end > ?", Time.current) }

  def current_batch
    batches.order(:order).not_ended.first
  end
end
