class AddDeactivatedAtToEntities < ActiveRecord::Migration[6.1]
  def change
    add_column :events, :deactivated_at, :boolean
    add_column :day_uses, :deactivated_at, :boolean
    add_column :memberships, :deactivated_at, :boolean
  end
end
