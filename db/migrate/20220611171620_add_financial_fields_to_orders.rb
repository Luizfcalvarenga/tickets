class AddFinancialFieldsToOrders < ActiveRecord::Migration[6.1]
  def change
    add_column :orders, :number_of_installments, :integer
    change_column :orders, :net_value, 'integer USING CAST(net_value AS integer)'
    change_column :orders, :value, 'integer USING CAST(value AS integer)'

    Order.all.select { |o| o.order_items.blank? }.each(&:destroy)

    Order.find_each do |order|
      order.update(number_of_installments: 1)
    end
  end
end

