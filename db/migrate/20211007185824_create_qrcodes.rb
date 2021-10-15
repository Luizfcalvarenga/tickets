class CreateQrcodes < ActiveRecord::Migration[6.1]
  def change
    create_table :qrcodes do |t|
      t.string :svg_source
      t.string :identifier
      t.references :event, foreign_key: true
      t.references :membership, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.decimal :amount_paid

      t.timestamps
    end
  end
end
