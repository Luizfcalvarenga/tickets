class CreateMembershipEvents < ActiveRecord::Migration[6.1]
  def change
    create_table :membership_events do |t|
      t.references :event, null: false, foreign_key: true
      t.references :membership, null: false, foreign_key: true
      t.boolean :free
      t.decimal :discount

      t.timestamps
    end
  end
end
