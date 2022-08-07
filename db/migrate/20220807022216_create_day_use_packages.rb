class CreateDayUsePackages < ActiveRecord::Migration[6.1]
  def change
    create_table :day_use_packages do |t|
      t.references :day_use, null: false, foreign_key: true
      t.string :description
      t.integer :quantity_of_passes
      t.datetime :deactivated_at
      t.string :kind
      t.integer :discount

      t.timestamps
    end

    add_reference :day_use_packages, :created_by, foreign_key: { to_table: :users }
  end
end
