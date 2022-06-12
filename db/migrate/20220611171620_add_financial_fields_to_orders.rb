class AddFinancialFieldsToOrders < ActiveRecord::Migration[6.1]
  def change
    add_column :orders, :reference_value_in_cents, :integer
    add_column :orders, :number_of_installments, :integer
    add_column :orders, :amount_to_transfer_to_partner, :integer
    add_column :orders, :amount_to_transfer_to_novamente_in_cents, :integer
    change_column :orders, :net_value, 'integer USING CAST(net_value AS integer)'
    change_column :orders, :value, 'integer USING CAST(value AS integer)'

    Order.find_each do |order|
      order.calculate_and_set_financial_values!
      order.update(number_of_installments: 1)
    end
  end
end

