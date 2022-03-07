class DayUseSchedulePassType < ApplicationRecord
  belongs_to :day_use_schedule

  has_many :passes

  scope :active, -> { where(deleted_at: nil) }

  def partner
    day_use_schedule.day_use.partner
  end
end
