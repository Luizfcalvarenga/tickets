class CreateCoupons < ActiveRecord::Migration[6.1]
  def change
    create_table :coupons do |t|
      t.references :entity, polymorphic: true, null: false
      t.integer :redemption_limit
      t.datetime :valid_until
      t.string :code
      t.string :kind
      t.integer :discount
      t.datetime :deactivated_at

      t.timestamps
    end
  end
end
