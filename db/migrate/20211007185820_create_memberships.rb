class CreateMemberships < ActiveRecord::Migration[6.1]
  def change
    create_table :memberships do |t|
      t.string :name
      t.string :short_description
      t.string :description
      t.integer :price_in_cents
      t.references :partner, null: false

      t.timestamps
    end
  end
end
