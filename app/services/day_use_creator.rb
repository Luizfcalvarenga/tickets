class DayUseCreator
  attr_reader :day_use, :params, :current_user
  def initialize(params, current_user)
    @params = params
    @current_user = current_user
  end

  def call
    ActiveRecord::Base.transaction do  
      day_use = DayUse.create!(day_use_params)
      day_use.create_default_questions

      day_use_schedule_params.each do |day_use_schedule_param|
        day_use_schedule = DayUseSchedule.create!(
          weekday: day_use_schedule_param[:weekday],
          name: day_use_schedule_param[:name],
          description: day_use_schedule_param[:description],
          opens_at: day_use_schedule_param[:opens_at],
          closes_at: day_use_schedule_param[:closes_at],
          photo: day_use_schedule_param[:photo],
          quantity_per_slot: day_use_schedule_param[:quantity_per_slot],
          slot_duration_in_minutes: day_use_schedule_param[:slot_duration_in_minutes],
          day_use: day_use,
        )

        (day_use_schedule_param[:pass_types] || []).each do |pass_type_param|
          DayUseSchedulePassType.create!(
            day_use_schedule: day_use_schedule,
            name: pass_type_param[:name],
            price_in_cents: pass_type_param[:price_in_cents]
          )
        end
      end
    end

    return true
  # rescue
    # return false
  end

  private

  def day_use_params
    params.require(:day_use).permit(:name, :description, :photo, :terms_of_use).merge(partner: current_user.partner)
  end

  def day_use_schedule_params
    params.require(:day_use).permit(day_use_schedules: [:weekday, :name, :description, :photo, :opens_at, :closes_at, :price_in_cents, :quantity_per_slot, :slot_duration_in_minutes, pass_types: [:id, :name, :price_in_cents]])[:day_use_schedules]
  end
end
