class CreateDayUses < ActiveRecord::Migration[6.1]
  def change
    create_table :day_uses do |t|
      t.string :name
      t.string :location
      t.text :description
      t.references :partner, null: false, foreign_key: true

      t.timestamps
    end
  end
end
