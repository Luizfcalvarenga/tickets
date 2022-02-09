class CreateEventQuestionBatches < ActiveRecord::Migration[6.1]
  def change
    create_table :event_question_batches do |t|
      t.references :event_question, null: false, foreign_key: true
      t.references :event_batch, null: false, foreign_key: true

      t.timestamps
    end
  end
end
