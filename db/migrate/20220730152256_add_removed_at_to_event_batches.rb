class AddRemovedAtToEventBatches < ActiveRecord::Migration[6.1]
  def change
    add_column :event_batches, :removed_at, :datetime
  end
end
