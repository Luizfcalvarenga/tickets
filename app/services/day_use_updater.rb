class DayUseUpdater
  attr_reader :day_use, :params
  def initialize(day_use, params)
    @day_use = day_use
    @params = params
  end

  def call
    ActiveRecord::Base.transaction do  
      @day_use.update!(day_use_params)

      day_use_schedule_params.each do |day_use_schedule_param|
        day_use_schedule = day_use.day_use_schedules.find_by(weekday: day_use_schedule_param[:weekday])

        day_use_schedule.update!(
          name: day_use_schedule_param[:name],
          description: day_use_schedule_param[:description],
          opens_at: day_use_schedule_param[:opens_at],
          closes_at: day_use_schedule_param[:closes_at],
          quantity_per_slot: day_use_schedule_param[:quantity_per_slot],
          slot_duration_in_minutes: day_use_schedule_param[:slot_duration_in_minutes],
        )

        removed_pass_types(day_use_schedule).update_all(deleted_at: Time.current)

        pass_types_to_update(day_use_schedule).each do |pass_type_param| 
          pass_type = DayUseSchedulePassType.find(pass_type_param[:id])
          
          update_pass_type = pass_type.update(
            name: pass_type_param[:name],
            price_in_cents: pass_type_param[:price_in_cents]
          )

          if !update_pass_type 
            errors << {weekday: pass_type.day_use_schedule.weekday, error: pass_type.errors.full_messages.join(", ")}
          end   
        end

        new_pass_types(day_use_schedule).each do |pass_type_param|
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

  def removed_pass_types(day_use_schedule)
    day_use_schedule.day_use_schedule_pass_types.where.not(id: received_pass_types_ids(day_use_schedule))
  end

  def pass_types_to_update(day_use_schedule)
    (day_use_schedule_params.find { |dusp| dusp[:weekday] === day_use_schedule.weekday }[:pass_types] || []).select{ |dusp| dusp[:id].present? }
  end

  def new_pass_types(day_use_schedule)
    (day_use_schedule_params.find { |dusp| dusp[:weekday] === day_use_schedule.weekday }[:pass_types] || []).select{ |dusp| dusp[:id].blank? }
  end

  def received_pass_types_ids(day_use_schedule)
    (day_use_schedule_params.find { |dusp| dusp[:weekday] === day_use_schedule.weekday }[:pass_types] || []).sort_by { |dusp| dusp.is_a?(EventBatch) ? dusp.order : dusp[:order] }.map{ |dusp| dusp[:id]}.compact
  end

  private

  def day_use_params
    params.require(:day_use).permit(:name, :description, :photo, :terms_of_use)
  end

  def day_use_schedule_params
    params.require(:day_use).permit(day_use_schedules: [:weekday, :name, :description, :opens_at, :closes_at, :price_in_cents, :quantity_per_slot, :slot_duration_in_minutes, pass_types: [:id, :name, :price_in_cents]])[:day_use_schedules]
  end
end
