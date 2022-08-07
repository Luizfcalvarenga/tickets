class DayUseSchedule < ApplicationRecord
  include ::ModelConcern

  belongs_to :day_use

  has_many :passes
  has_many :day_use_schedule_pass_types

  has_one_attached :photo

  delegate :partner, to: :day_use

  validate :must_have_name_if_day_is_open
  validate :must_have_closing_hours_if_has_start_hours_and_vice_versa
  validate :closing_hours_must_be_after_opening_hours

  def must_have_name_if_day_is_open
    if open? && name.blank?
      errors.add(:name, "não pode ficar em branco se o dia estiver aberto")
    end
  end

  def must_have_closing_hours_if_has_start_hours_and_vice_versa
    if opens_at.present? && closes_at.blank?
      errors.add(:closes_at, "Deve ter horário de fechamento caso tenha horário de abertura")
    end
    if closes_at.present? && opens_at.blank?
      errors.add(:opens_at, "Deve ter horário de abertura caso tenha horário de fechamento")
    end
  end

  def closing_hours_must_be_after_opening_hours
    if opens_at.present? && closes_at.present? && opens_at > closes_at
      errors.add(:closes_at, "O horário de fechamento deve ser após o horário de abertura")
    end
  end

  def self.order_by_weekday
    order(Arel.sql("CASE day_use_schedules.weekday WHEN 'monday' THEN 0 " \
        "WHEN 'tuesday' THEN 1 " \
        "WHEN 'wednesday' THEN 2 " \
        "WHEN 'thursday' THEN 3 " \
        "WHEN 'friday' THEN 4 " \
        "WHEN 'saturday' THEN 5 " \
        "WHEN 'sunday' THEN 6 END"))
  end

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
    return [] if !open?

    date = date.to_datetime.asctime.in_time_zone("Brazil/East")

    day_use_blocks_for_date = day_use.day_use_blocks.where("day_use_blocks.weekday = 'all' or day_use_blocks.weekday = ? or (day_use_blocks.block_date >= ? AND day_use_blocks.block_date <= ?)", weekday, date.beginning_of_day, date.end_of_day)
    
    start_checkpoints = [opens_at]
    end_checkpoints = [closes_at]

    day_use_blocks_for_date.each do |day_use_block|
      start_checkpoints << day_use_block.end_time if day_use_blocks_for_date.where.not(id: day_use_block.id).all? { |dub| (dub.start_time > day_use_block.end_time && dub.end_time > day_use_block.end_time) || (dub.start_time < day_use_block.end_time && dub.end_time < day_use_block.end_time) }
      end_checkpoints << day_use_block.start_time if day_use_blocks_for_date.where.not(id: day_use_block.id).all? { |dub| (dub.start_time > day_use_block.start_time && dub.end_time > day_use_block.start_time) || (dub.start_time < day_use_block.start_time && dub.end_time < day_use_block.start_time) }
    end

    start_checkpoints.map! { |sc| sc.change(day: date.day, month: date.month, year: date.year) }.sort!
    end_checkpoints.map! { |ec| ec.change(day: date.day, month: date.month, year: date.year) }.sort!
    
    open_intervals = start_checkpoints.each_with_index.map { |start_time, index| [start_time, end_checkpoints[index]] }

    slots = []

    number_of_slots = ((closes_at - opens_at)/(60 * sanitized_slot_duration_in_minutes).floor).to_i
  
    number_of_slots.times do |i|
      start_time = date.change(hour: opens_at.hour, min: opens_at.min) + (i * sanitized_slot_duration_in_minutes).minutes
      end_time = start_time + sanitized_slot_duration_in_minutes.minutes
      available_passes_for_slot = open_intervals.any? { |interval| start_time.between?(interval.first, interval.last) } ? day_use_schedule_pass_types.active.available_for_start_time(datetime_in_current_timezone(start_time)) : []
      slots << {
        start_time: start_time,
        end_time: end_time,
        available_pass_types: available_passes_for_slot.map { |pass_type| {
          **pass_type.attributes, available_quantity: pass_type.available_quantity_for_slot(start_time)
        }}
      }
    end

    slots
  end

  def sanitized_slot_duration_in_minutes
    slot_duration_in_minutes.presence || (closes_at - opens_at)/60
  end

  def display_photo
    day_use.display_photo
  end
end
