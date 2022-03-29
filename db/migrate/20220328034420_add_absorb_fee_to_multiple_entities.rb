class AddAbsorbFeeToMultipleEntities < ActiveRecord::Migration[6.1]
  def change
    add_column :events, :fee_percentage, :float
    add_column :events, :absorb_fee, :boolean
    add_column :day_uses, :fee_percentage, :float
    add_column :day_uses, :absorb_fee, :boolean
    add_column :memberships, :fee_percentage, :float
    add_column :memberships, :absorb_fee, :boolean
    add_column :order_items, :absorb_fee, :boolean
    add_column :passes, :absorb_fee, :boolean
  end
end
