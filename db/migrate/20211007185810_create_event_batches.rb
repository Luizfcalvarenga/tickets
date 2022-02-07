class CreateEventBatches < ActiveRecord::Migration[6.1]
  def change
    create_table :event_batches do |t|
      t.references :event, null: false, foreign_key: true
      t.string :name
      t.string :pass_type
      t.integer :quantity
      t.integer :price_in_cents
      t.integer :order
      t.datetime :ended_at
      t.datetime :ends_at

      t.timestamps
    end
]  end
end
