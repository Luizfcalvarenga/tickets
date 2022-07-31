class CreateUserMembershipRenewals < ActiveRecord::Migration[6.1]
  def change
    create_table :user_membership_renewals do |t|
      t.references :user_membership, null: false, foreign_key: true
      t.datetime :renewal_date

      t.timestamps
    end

    add_reference :order_items, :user_membership_renewal, foreign_key: true
  end
end
