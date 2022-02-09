class DayUse < ApplicationRecord
  belongs_to :partner

  has_rich_text :description

  has_one_attached :photo

  has_many :day_use_schedules, dependent: :destroy
  has_many :day_use_blocks, dependent: :destroy

  scope :open_for_weekday, ->(weekday) { joins(:day_use_schedules).where("day_use_schedules.start_time is not null and day_use_schedules.end_time is not null and day_use_schedules.weekday = ?", weekday) }
end
