class CreateReads < ActiveRecord::Migration[6.1]
  def change
    create_table :reads do |t|
      t.references :pass, null: false, foreign_key: true
      t.string :read_by
      t.boolean :result
      t.string :main_line
      t.string :secondary_line

      t.timestamps
    end

    add_reference :reads, :read_by, foreign_key: { to_table: :users }
  end
end
