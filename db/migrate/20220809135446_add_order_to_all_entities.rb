class AddOrderToAllEntities < ActiveRecord::Migration[6.1]
  def change
    add_column :events, :order, :integer, default: 0
    add_column :day_uses, :order, :integer, default: 0
    add_column :memberships, :order, :integer, default: 0
  end
end
