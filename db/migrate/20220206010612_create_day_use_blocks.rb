class CreateDayUseBlocks < ActiveRecord::Migration[6.1]
  def change
    create_table :day_use_blocks do |t|
      t.references :day_use
      t.datetime :block_date

      t.timestamps
    ends
  end
end
