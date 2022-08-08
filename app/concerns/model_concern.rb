module ModelConcern
  extend ActiveSupport::Concern

  included do
    def weekday_for_wday(wday)
      ["sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday"][wday]
    end 
    
    def weekday_translation(weekday)
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

    def datetime_in_current_timezone(datetime)
      datetime.in_time_zone(Time.zone.name).change(hour: datetime.hour, min: datetime.min, sec: datetime.sec)
    end
  end
end
