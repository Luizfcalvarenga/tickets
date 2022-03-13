class CreateDayUseBlocks < ActiveRecord::Migration[6.1]
  def change
    create_table :day_use_blocks do |t|
      t.references :day_use
      t.datetime :block_date
      t.string :weekday
      t.datetime :start_time
      t.datetime :end_time

      t.timestamps
    end

    add_reference :day_use_blocks, :created_by, foreign_key: { to_table: :users }
  end
end
