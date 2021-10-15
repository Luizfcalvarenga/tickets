class CreateReads < ActiveRecord::Migration[6.1]
  def change
    create_table :reads do |t|
      t.references :qrcode, null: false, foreign_key: true
      t.references :session, null: false, foreign_key: true
      t.boolean :result

      t.timestamps
    end
  end
end
