class DropUnnecessaryFinancialFieldsFromOrdersAndOrderItems < ActiveRecord::Migration[6.1]
  def change
    remove_column :orders, :amount_to_transfer_to_novamente_in_cents
    remove_column :orders, :amount_to_transfer_to_partner
    remove_column :orders, :reference_value_in_cents
    remove_column :order_items, :total_in_cents
  end
end
