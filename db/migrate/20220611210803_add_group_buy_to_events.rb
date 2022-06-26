class AddGroupBuyToEvents < ActiveRecord::Migration[6.1]
  def change
    add_column :events, :group_buy, :boolean, default: false
    add_column :events, :group_buy_code, :string
    add_column :passes, :group_buy_code, :string
  end
end
