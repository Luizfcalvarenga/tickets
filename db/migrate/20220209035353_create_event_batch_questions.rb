class CreateEventBatchQuestions < ActiveRecord::Migration[6.1]
  def change
    create_table :event_batch_questions do |t|
      t.references :question, null: false, foreign_key: true
      t.references :event_batch, null: false, foreign_key: true

      t.timestamps
    end
  end
end
