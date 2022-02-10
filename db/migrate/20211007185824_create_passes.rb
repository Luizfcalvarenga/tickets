class CreatePasses < ActiveRecord::Migration[6.1]
  def change
    create_table :passes do |t|
      t.string :qrcode_svg
      t.string :name
      t.string :identifier
      t.references :event, foreign_key: true
      t.references :event_batch, foreign_key: true
      t.references :membership, foreign_key: true
      t.references :day_use_schedule, foreign_key: true
      t.references :partner, foreign_key: true
      t.references :order_item, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.decimal :amount_paid

      t.timestamps
    end
  end
end
