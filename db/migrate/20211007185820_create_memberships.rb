class CreateMemberships < ActiveRecord::Migration[6.1]
  def change
    create_table :memberships do |t|
      t.string :name
      t.string :short_description
      t.text :description
      t.integer :price_in_cents
      t.references :partner, null: false
      t.string :iugu_plan_id

      t.timestamps
    end
  end
end
