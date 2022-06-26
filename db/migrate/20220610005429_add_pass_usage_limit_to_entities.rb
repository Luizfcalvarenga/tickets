class AddPassUsageLimitToEntities < ActiveRecord::Migration[6.1]
  def change
    add_column :memberships, :monthly_pass_usage_limit, :integer, default: 9999
    add_column :event_batches, :number_of_accesses_granted, :integer, default: 1
    add_column :day_use_schedule_pass_types, :number_of_accesses_granted, :integer, default: 1
  end
end
