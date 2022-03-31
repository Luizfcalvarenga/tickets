class AddFreeToPass < ActiveRecord::Migration[6.1]
  def change
    add_column :passes, :free, :boolean, default: false
    add_column :orders, :free, :boolean, default: false
  end
end
