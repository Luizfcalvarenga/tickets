class AddDeactivatedAtToPass < ActiveRecord::Migration[6.1]
  def change
    add_column :passes, :deactivated_at, :datetime
    add_column :user_memberships, :deactivated_at, :datetime
  end
end
