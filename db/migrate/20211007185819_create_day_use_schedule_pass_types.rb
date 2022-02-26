class CreateDayUseSchedulePassTypes < ActiveRecord::Migration[6.1]
  def change
    create_table :day_use_schedule_pass_types do |t|
      t.string :name
      t.integer :price_in_cents
      t.datetime :deleted_at
      t.references :day_use_schedule, null: false, foreign_key: true

      t.timestamps
    end
  end
end
