class CreateOrders < ActiveRecord::Migration[6.1]
  def change
    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true
      t.string :invoice_id
      t.string :invoice_url
      t.string :invoice_pdf
      t.string :invoice_status
      t.string :net_value
      t.integer :price_in_cents
      t.string :value
      t.datetime :invoice_paid_at
      t.string :status

      t.timestamps
    end

    add_reference :orders, :created_by, foreign_key: { to_table: :users }
    add_reference :orders, :directly_generated_by, foreign_key: { to_table: :users }
  end
end
