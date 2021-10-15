class CreateBatches < ActiveRecord::Migration[6.1]
  def change
    create_table :batches do |t|
      t.references :event, null: false, foreign_key: true
      t.string :name
      t.integer :quantity
      t.decimal :price
      t.integer :order
      t.datetime :ended_at

      t.timestamps
    end

    add_reference :qrcodes, :batch
  end
end
