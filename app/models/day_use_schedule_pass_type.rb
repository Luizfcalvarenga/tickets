class DayUseSchedulePassType < ApplicationRecord
  belongs_to :day_use_schedule

  has_many :passes
  
  validates :name, :price_in_cents, presence: true
  validates :price_in_cents, numericality: {  only_integer: true }
  validates :name, uniqueness: { scope: [:day_use_schedule_id, :deleted_at], message: "Já existe um tipo de passe com esse nome para esse dia" }

  scope :active, -> { where(deleted_at: nil) }
  scope :available_for_start_time, ->(start_time) { joins(:day_use_schedule).where('day_use_schedules.quantity_per_slot IS NULL OR (select count(distinct passes.id) from passes where passes.day_use_schedule_pass_type_id = day_use_schedule_pass_types.id and passes.start_time = ?) < day_use_schedules.quantity_per_slot', start_time) }

  def self.order_by_weekday
    order(Arel.sql("CASE day_use_schedules.weekday WHEN 'monday' THEN 0 " \
        "WHEN 'tuesday' THEN 1 " \
        "WHEN 'wednesday' THEN 2 " \
        "WHEN 'thursday' THEN 3 " \
        "WHEN 'friday' THEN 4 " \
        "WHEN 'saturday' THEN 5 " \
        "WHEN 'sunday' THEN 6 END"))
  end

  def day_use
    @day_use ||= day_use_schedule.day_use
  end

  delegate :fee_percentage, :absorb_fee, to: :day_use

  def total_in_cents
    day_use.absorb_fee ? price_in_cents : (price_in_cents * (1 + fee_percentage / 100))
  end

  def partner
    day_use_schedule.day_use.partner
  end

  def available_quantity_for_slot(start_time)
    return 9999 if day_use_schedule.quantity_per_slot.blank?
    
    day_use_schedule.quantity_per_slot - Pass.where(day_use_schedule_pass_type_id: id, start_time: start_time).count
  end

  scope :active, -> { where(deleted_at: nil) }
  scope :inactive, -> { where.not(deleted_at: nil) }
end
