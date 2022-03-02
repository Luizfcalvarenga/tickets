class CreateEvents < ActiveRecord::Migration[6.1]
  def change
    create_table :events do |t|
      t.string :name
      t.text :description
      t.datetime :scheduled_start
      t.datetime :scheduled_end
      t.references :partner, null: false
      t.string :cep
      t.string :street_name
      t.string :street_number
      t.string :neighborhood
      t.string :address_complement
      t.datetime :released_at
      t.datetime :sales_started_at
      t.datetime :sales_finished_at
      t.references :city, null: false, foreign_key: true
      t.references :state, null: false, foreign_key: true
      t.timestamps
    end

    add_reference :events, :created_by, foreign_key: { to_table: :users }
  end
end
