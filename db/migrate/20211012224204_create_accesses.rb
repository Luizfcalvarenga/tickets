class CreateAccesses < ActiveRecord::Migration[6.1]
  def change
    create_table :accesses do |t|
      t.references :pass, foreign_key: true
      t.references :read, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_reference :accesses, :granted_by, foreign_key: { to_table: :users }
  end
end
