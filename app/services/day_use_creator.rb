class DayUseCreator
  attr_reader :day_use, :params, :current_user, :errors
  def initialize(params, current_user)
    @params = params
    @current_user = current_user
    @errors = {day_use: [], day_use_schedules: []}
  end

  def call
    ActiveRecord::Base.transaction do  
      @day_use = DayUse.create(day_use_params)

      raise if !@day_use.persisted?

      @day_use.create_default_questions

      day_use_schedule_params.each do |day_use_schedule_param|
        day_use_schedule = DayUseSchedule.create(
          weekday: day_use_schedule_param[:weekday],
          name: day_use_schedule_param[:name],
          description: day_use_schedule_param[:description],
          opens_at: day_use_schedule_param[:opens_at],
          closes_at: day_use_schedule_param[:closes_at],
          photo: day_use_schedule_param[:photo],
          quantity_per_slot: day_use_schedule_param[:quantity_per_slot],
          slot_duration_in_minutes: day_use_schedule_param[:slot_duration_in_minutes],
          day_use: @day_use,
        )

        if !day_use_schedule.persisted? 
          @errors[:day_use_schedules] << {
            weekday: day_use_schedule_param[:weekday],
            pass_types: [],
            error: day_use_schedule.errors
          }
        end

        pass_types = (day_use_schedule_param[:day_use_schedule_pass_types] || []).map do |pass_type_param|
          day_use_schedule_pass_type = DayUseSchedulePassType.create(
            day_use_schedule: day_use_schedule,
            name: pass_type_param[:name],
            number_of_accesses_granted: pass_type_param[:number_of_accesses_granted],
            price_in_cents: pass_type_param[:price_in_cents]
          )
        end
        
        current_errors = @errors[:day_use_schedules]
        pass_types.each_with_index do |pass_type, index|
          current_errors << {weekday: day_use_schedule_param[:weekday], pass_types: []  } if current_errors.find { |error| error[:weekday] == day_use_schedule_param[:weekday] }.blank?
          current_errors.find { |error| error[:weekday] == day_use_schedule_param[:weekday] }[:pass_types][index] = pass_type.errors
        end
      end

      raise if @errors[:day_use_schedules].present?
    end

    return true
  rescue
    return false
  end

  private

  def day_use_params
    params.require(:day_use).permit(:name, :description, :photo, :terms_of_use).merge(partner: current_user.partner)
  end

  def day_use_schedule_params
    params.require(:day_use).permit(day_use_schedules: [:weekday, :name, :description, :photo, :opens_at, :closes_at, :price_in_cents, :quantity_per_slot, :slot_duration_in_minutes, day_use_schedule_pass_types: [:id, :name, :price_in_cents, :number_of_accesses_granted]])[:day_use_schedules]
  end
end
