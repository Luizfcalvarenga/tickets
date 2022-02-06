class CreateOrderItems < ActiveRecord::Migration[6.1]
  def change
    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true
      t.references :event_batch, null: false, foreign_key: true
      t.references :day_use, null: false, foreign_key: true
      t.integer :price_in_cents

      t.timestamps
    end
  end
end
