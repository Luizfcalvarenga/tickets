class AddPublicUrlToEvents < ActiveRecord::Migration[6.1]
  def change
    add_column :events, :slug, :string
    add_column :events, :hide_from_events_index, :boolean, default: false
  end
end
