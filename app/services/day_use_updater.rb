class DayUseUpdater
  attr_reader :day_use, :params, :errors
  def initialize(day_use, params)
    @day_use = day_use
    @params = params
    @errors = {day_use: [], day_use_schedules: []}
  end

  def call
    ActiveRecord::Base.transaction do  
      @day_use.update(day_use_params)

      day_use_schedule_params.each do |day_use_schedule_param|
        day_use_schedule = day_use.day_use_schedules.find_by(weekday: day_use_schedule_param[:weekday])

        update_result = day_use_schedule.update(
          name: day_use_schedule_param[:name],
          description: day_use_schedule_param[:description],
          opens_at: day_use_schedule_param[:opens_at],
          closes_at: day_use_schedule_param[:closes_at],
          quantity_per_slot: day_use_schedule_param[:quantity_per_slot],
          slot_duration_in_minutes: day_use_schedule_param[:slot_duration_in_minutes],
        )
        if !update_result
          @errors[:day_use_schedules] << {
            weekday: day_use_schedule_param[:weekday],
            pass_types: [],
            error: day_use_schedule.errors
          }
        end

        update_result = day_use_schedule.update(photo: day_use_schedule_param[:photo]) if day_use_schedule_param[:photo].present?
        if !update_result 
          @errors[:day_use_schedules] << {
            weekday: day_use_schedule_param[:weekday],
            pass_types: [],
            error: day_use_schedule.errors
          }
        end

        removed_pass_types(day_use_schedule).update_all(deleted_at: Time.current)

        pass_types_to_update(day_use_schedule).each do |pass_type_param| 
          pass_type = DayUseSchedulePassType.find(pass_type_param[:id])
          
          update_pass_type = pass_type.update(
            name: pass_type_param[:name],
            price_in_cents: pass_type_param[:price_in_cents],
            number_of_accesses_granted: pass_type_param[:number_of_accesses_granted],
          )

          if !update_pass_type 
            current_errors = @errors[:day_use_schedules]
            current_errors_for_day_use_schedule = current_errors.find { |error| error[:weekday] == day_use_schedule_param[:weekday] }
            pass_type_form_index = (day_use_schedule_params.find { |dusp| dusp[:weekday] == day_use_schedule.weekday }[:day_use_schedule_pass_types]).index(pass_type_param)
            current_errors_for_day_use_schedule[pass_type_form_index] = pass_type.errors
          end   
        end
        
        new_pass_types(day_use_schedule).each do |pass_type_param|
          pass_type = DayUseSchedulePassType.create(
            day_use_schedule: day_use_schedule,
            name: pass_type_param[:name],
            price_in_cents: pass_type_param[:price_in_cents],
            number_of_accesses_granted: pass_type_param[:number_of_accesses_granted],
          )

          if !pass_type.persisted? 
            current_errors = @errors[:day_use_schedules]
            current_errors << {weekday: day_use_schedule_param[:weekday], pass_types: []  } if current_errors.find { |error| error[:weekday] == day_use_schedule_param[:weekday] }.blank?
            pass_type_form_index = (day_use_schedule_params.find { |dusp| dusp[:weekday] == day_use_schedule.weekday }[:day_use_schedule_pass_types]).index(pass_type_param)
            current_errors.find { |error| error[:weekday] == day_use_schedule_param[:weekday] }[:pass_types][pass_type_form_index] = pass_type.errors
          end   
        end
      end

      raise if @day_use.errors.present?
      raise if @errors[:day_use_schedules].present?
    end

    return true
  rescue
    return false
  end

  def removed_pass_types(day_use_schedule)
    day_use_schedule.day_use_schedule_pass_types.where.not(id: received_pass_types_ids(day_use_schedule))
  end

  def pass_types_to_update(day_use_schedule)
    (day_use_schedule_params.find { |dusp| dusp[:weekday] == day_use_schedule.weekday }[:day_use_schedule_pass_types] || []).select{ |dusp| dusp[:id].present? }
  end

  def new_pass_types(day_use_schedule)
    (day_use_schedule_params.find { |dusp| dusp[:weekday] == day_use_schedule.weekday }[:day_use_schedule_pass_types] || []).select{ |dusp| dusp[:id].blank? }
  end

  def received_pass_types_ids(day_use_schedule)
    (day_use_schedule_params.find { |dusp| dusp[:weekday] == day_use_schedule.weekday }[:day_use_schedule_pass_types] || []).map{ |dusp| dusp[:id]}.compact
  end

  private

  def day_use_params
    params.require(:day_use).permit(:name, :description, :photo, :terms_of_use)
  end

  def day_use_schedule_params
    params.require(:day_use).permit(day_use_schedules: [:weekday, :name, :description, :photo, :opens_at, :closes_at, :price_in_cents, :quantity_per_slot, :slot_duration_in_minutes, day_use_schedule_pass_types: [:id, :name, :price_in_cents, :number_of_accesses_granted]])[:day_use_schedules]
  end
end
