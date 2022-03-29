class AddApprovedAtToMultipleEntities < ActiveRecord::Migration[6.1]
  def change
    add_column :events, :approved_at, :datetime
    add_column :day_uses, :approved_at, :datetime
    add_column :memberships, :approved_at, :datetime
    add_reference :events, :approved_by, foreign_key: { to_table: :users }
    add_reference :day_uses, :approved_by, foreign_key: { to_table: :users }
    add_reference :memberships, :approved_by, foreign_key: { to_table: :users }
  end
end
