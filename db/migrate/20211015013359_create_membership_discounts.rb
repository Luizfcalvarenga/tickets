class CreateMembershipDiscounts < ActiveRecord::Migration[6.1]
  def change
    create_table :membership_discounts do |t|
      t.references :event, foreign_key: true
      t.references :day_use, foreign_key: true
      t.references :membership, null: false, foreign_key: true
      t.decimal :discount_percentage

      t.timestamps
    end
  end
end
