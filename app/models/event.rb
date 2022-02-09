class Event < ApplicationRecord
  belongs_to :partner
  belongs_to :created_by, class_name: "User"
  belongs_to :city
  belongs_to :state

  has_one_attached :photo
  has_many :event_batches, dependent: :destroy
  has_many :accesses
  has_many :event_questions, dependent: :destroy
  has_many :event_communications
  
  has_many :passes
  has_many :accesses
  has_many :membership_discounts
  has_many :memberships, through: :membership_discounts

  has_rich_text :description

  scope :upcoming, -> { where("scheduled_end < ?", Time.current) }
  scope :happening_now, -> { where("scheduled_start > ? and scheduled_end < ?", Time.current, Time.current) }
  scope :past, -> { where("scheduled_end > ?", Time.current) }

  def open_batches
    event_batches.available.joins("left join event_batches eb on event_batches.pass_type = eb.pass_type and event_batches.order > eb.order").where("eb.order is null").order(:order)
  end
end
