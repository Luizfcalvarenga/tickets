class DayUseBlock < ApplicationRecord
  belongs_to :day_use
  belongs_to :created_by, class_name: "User", foreign_key: "created_by_id"

  def block_type
    block_date.present? ? "Data específica" : "Bloqueio recorrente"
  end

  def block_days
    return block_date.strftime("%d/%m/%Y") if block_date.present?

    {
      monday: "Toda segunda-feira",
      tuesday: "Toda terça-feira",
      wednesday: "Toda quarta-feira",
      thursday: "Toda quinta-feira",
      friday: "Toda sexta-feira",
      saturday: "Todo sábado",
      sunday: "Todo domingo",
      all: "Todos os dias",
    }[weekday.to_sym]
  end
end
