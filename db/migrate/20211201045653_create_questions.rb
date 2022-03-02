class CreateQuestions < ActiveRecord::Migration[6.1]
  def change
    create_table :questions do |t|
      t.references :event, foreign_key: true
      t.references :day_use, foreign_key: true
      t.string :prompt
      t.string :kind
      t.integer :order
      t.boolean :optional
      t.string :options, array: true, default: []
      t.boolean :default

      t.timestamps
    end
  end
end
