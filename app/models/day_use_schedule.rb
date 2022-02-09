class DayUseSchedule < ApplicationRecord
  belongs_to :day_use

  def weekday_display
    {
      monday: "Segunda-feira",
      tuesday: "Terça-feira",
      wednesday: "Quarta-feira",
      thursday: "Quinta-feira",
      friday: "Sexta-feira",
      saturday: "Sábado",
      sunday: "Domingo",
    }[weekday.to_sym]
  end

  def open?
    start_time.present? && end_time.present?
  end
end
