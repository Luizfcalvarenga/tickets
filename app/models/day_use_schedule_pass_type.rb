class DayUseSchedulePassType < ApplicationRecord
  belongs_to :day_use_schedule

  has_many :passes

  validates :name, :price_in_cents, presence: true
  validates :price_in_cents, numericality: {  only_integer: true }
  validates :name, uniqueness: { scope: [:day_use_schedule_id, :deleted_at], message: "Já existe um tipo de passe com esse nome para esse dia" }

  scope :active, -> { where(deleted_at: nil) }

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

  scope :active, -> { where(deleted_at: nil) }
  scope :inactive, -> { where.not(deleted_at: nil) }
end
