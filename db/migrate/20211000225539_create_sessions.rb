class CreateSessions < ActiveRecord::Migration[6.1]
  def change
    create_table :sessions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :event, foreign_key: true
      t.datetime :ended_at
      t.string :identifier

      t.timestamps
    end
  end
end
