class CreateDayUseSchedules < ActiveRecord::Migration[6.1]
  def change
    create_table :day_use_schedules do |t|
      t.string :weekday
      t.string :name
      t.text :description
      t.datetime :opens_at
      t.datetime :closes_at
      t.integer :slot_duration_in_minutes
      t.integer :quantity_per_slot
      t.references :day_use, null: false, foreign_key: true

      t.timestamps
    end
  end
end
