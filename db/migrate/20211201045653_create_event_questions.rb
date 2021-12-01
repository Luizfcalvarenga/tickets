class CreateEventQuestions < ActiveRecord::Migration[6.1]
  def change
    create_table :event_questions do |t|
      t.references :event, null: false, foreign_key: true
      t.string :prompt
      t.string :kind
      t.integer :order
      t.boolean :optional
      t.string :options, array: true, default: []

      t.timestamps
    end
  end
end
