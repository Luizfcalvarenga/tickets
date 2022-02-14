class CreateOrderItems < ActiveRecord::Migration[6.1]
  def change
    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true
      t.references :event_batch, foreign_key: true
      t.references :day_use_schedule, foreign_key: true
      t.datetime :start_time
      t.datetime :end_time
      t.integer :price_in_cents

      t.timestamps
    end
  end
end
