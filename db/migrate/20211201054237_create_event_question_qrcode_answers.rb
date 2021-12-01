class CreateEventQuestionQrcodeAnswers < ActiveRecord::Migration[6.1]
  def change
    create_table :event_question_qrcode_answers do |t|
      t.references :event_question, null: false, foreign_key: true
      t.references :qrcode, null: false, foreign_key: true
      t.string :value

      t.timestamps
    end
  end
end
