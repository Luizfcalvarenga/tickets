class CreateQuestionAnswers < ActiveRecord::Migration[6.1]
  def change
    create_table :question_answers do |t|
      t.references :event_question, null: false, foreign_key: true
      t.references :order_item, null: false, foreign_key: true
      t.string :value

      t.timestamps
    end
  end
end
