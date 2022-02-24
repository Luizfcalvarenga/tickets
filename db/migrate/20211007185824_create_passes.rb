class CreatePasses < ActiveRecord::Migration[6.1]
  def change
    create_table :passes do |t|
      t.string :qrcode_svg
      t.string :name
      t.string :identifier
      t.references :event, foreign_key: true
      t.references :event_batch, foreign_key: true
      t.references :user_membership, foreign_key: true
      t.references :day_use_schedule, foreign_key: true
      t.references :partner, foreign_key: true
      t.references :order_item, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.datetime :start_time
      t.datetime :end_time
      t.integer :price_in_cents
      t.float :fee_percentage, default: 10.0

      t.timestamps
    end
  end
end
