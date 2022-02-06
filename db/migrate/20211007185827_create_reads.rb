class CreateReads < ActiveRecord::Migration[6.1]
  def change
    create_table :reads do |t|
      t.references :pass, null: false, foreign_key: true
      t.boolean :result
      t.string :error
      t.string :error_details

      t.timestamps
    end
  end
end
