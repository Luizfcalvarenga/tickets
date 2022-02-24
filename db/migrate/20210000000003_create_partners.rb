class CreatePartners < ActiveRecord::Migration[6.1]
  def change
    create_table :partners do |t|
      t.string :name
      t.string :slug
      t.string :cnpj
      t.string :kind
      t.string :contact_phone_1
      t.string :contact_phone_2
      t.string :contact_email
      t.string :cep
      t.string :street_name
      t.string :street_number
      t.string :neighborhood
      t.string :address_complement
      t.float :fee_percentage, default: 10.0
      t.text :about
      t.references :city, null: false, foreign_key: true
      t.references :state, null: false, foreign_key: true
      t.timestamps
    end

    add_reference :partners, :main_contact, foreign_key: { to_table: :users }
  end
end
