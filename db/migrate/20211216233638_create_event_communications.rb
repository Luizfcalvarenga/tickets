class CreateEventCommunications < ActiveRecord::Migration[6.1]
  def change
    create_table :event_communications do |t|
      t.string :subject
      t.text :content
      t.references :event, null: false, foreign_key: true

      t.timestamps
    end
  end
end
