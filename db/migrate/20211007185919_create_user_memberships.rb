class CreateUserMemberships < ActiveRecord::Migration[6.1]
  def change
    create_table :user_memberships do |t|
      t.references :user, null: false, foreign_key: true
      t.references :membership, null: false, foreign_key: true
      t.datetime :ended_at, default: nil

      t.timestamps
    end
  end
end
