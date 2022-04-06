class AddMinimumSubscriptionMonthsToMemberships < ActiveRecord::Migration[6.1]
  def change
    add_column :memberships, :minimum_subscription_months, :integer, default: 0
  end
end
