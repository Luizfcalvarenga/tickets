class AddRecurrenceIntervalInMonthsToMembership < ActiveRecord::Migration[6.1]
  def change
    add_column :memberships, :recurrence_interval_in_months, :integer, default: 1
  end
end
