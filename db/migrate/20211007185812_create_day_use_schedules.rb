class CreateDayUseSchedules < ActiveRecord::Migration[6.1]
  def change
    create_table :day_use_schedules do |t|
      t.string :weekday
      t.string :name
      t.time :start_time
      t.time :end_time
      t.integer :price_in_cents
      t.references :day_use, null: false, foreign_key: true

      t.timestamps
    end
  end
end
