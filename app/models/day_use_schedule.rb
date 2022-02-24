class DayUseSchedule < ApplicationRecord
  belongs_to :day_use

  has_many :passes

  delegate :partner, to: :day_use

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
    opens_at.present? && closes_at.present?
  end

  def start_time(start_time)
    start_time
  end

  def end_time(end_time)
    end_time
  end

  def open_slots_for_date(date)
    date = date.to_datetime.asctime.in_time_zone("Brazil/East")
    
    number_of_slots = ((closes_at - opens_at)/(60 * slot_duration_in_minutes).floor).to_i

    slots = []

    number_of_slots.times do |i|
      start_time = date.change(hour: opens_at.hour, min: opens_at.min) + (i * slot_duration_in_minutes).minutes
      end_time = start_time + slot_duration_in_minutes.minutes
      slots << {
        start_time: start_time,
        end_time: end_time,
        order_item_count: OrderItem.where(day_use_schedule: self, start_time: start_time).count
      }
    end

    slots.reject { |slot| slot[:order_item_count] >= quantity_per_slot }
  end
end
