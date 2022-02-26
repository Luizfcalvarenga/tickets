class DayUseSchedulePassType < ApplicationRecord
  belongs_to :day_use_schedule

  has_many :passes

  def partner
    day_use_schedule.day_use.partner
  end
end
