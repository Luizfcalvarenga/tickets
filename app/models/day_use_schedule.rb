class DayUseSchedule < ApplicationRecord
  belongs_to :day_use

  has_many :passes
  has_many :day_use_schedule_pass_types

  has_one_attached :photo

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

  def open_slots_for_date(date)
    return [] if !open? || day_use.day_use_blocks.exists?(day_use.day_use_blocks.where(block_date: date.beginning_of_day..date.end_of_day))

    date = date.to_datetime.asctime.in_time_zone("Brazil/East")

    day_use_blocks_for_date = day_use.day_use_blocks.where("day_use_blocks.weekday = 'all' or day_use_blocks.weekday = ?", weekday)
    
    start_checkpoints = [opens_at]
    end_checkpoints = [closes_at]

    day_use_blocks_for_date.each do |day_use_block|
      start_checkpoints << day_use_block.end_time if day_use_blocks_for_date.where.not(id: day_use_block.id).all? { |dub| (dub.start_time > day_use_block.end_time && dub.end_time > day_use_block.end_time) || (dub.start_time < day_use_block.end_time && dub.end_time < day_use_block.end_time) }
      end_checkpoints << day_use_block.start_time if day_use_blocks_for_date.where.not(id: day_use_block.id).all? { |dub| (dub.start_time > day_use_block.start_time && dub.end_time > day_use_block.start_time) || (dub.start_time < day_use_block.start_time && dub.end_time < day_use_block.start_time) }
    end

    start_checkpoints.sort!
    end_checkpoints.sort!
    
    intervals = start_checkpoints.each_with_index.map { |start_time, index| [start_time, end_checkpoints[index]] }

    slots = []

    intervals.each do |interval|
      number_of_slots = ((interval.last - interval.first)/(60 * sanitized_slot_duration_in_minutes).floor).to_i
    
      number_of_slots.times do |i|
        start_time = date.change(hour: interval.first.hour, min: opens_at.min) + (i * sanitized_slot_duration_in_minutes).minutes
        end_time = start_time + sanitized_slot_duration_in_minutes.minutes
        slots << {
          start_time: start_time,
          end_time: end_time,
          order_item_count: OrderItem.where(day_use_schedule_pass_type_id: day_use_schedule_pass_types.ids, start_time: start_time).count
        }
      end
    end

    return slots if quantity_per_slot.blank?

    slots.reject { |slot| slot[:order_item_count] >= quantity_per_slot }
  end

  def sanitized_slot_duration_in_minutes
    slot_duration_in_minutes.presence || (closes_at - opens_at)/60
  end
end
