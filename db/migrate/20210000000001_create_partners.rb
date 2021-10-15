class CreatePartners < ActiveRecord::Migration[6.1]
  def change
    create_table :partners do |t|
      t.string :name
      t.string :cnpj
      t.string :kind
      t.string :phone_number
      t.string :cep
      t.string :street_name
      t.string :street_number
      t.string :neighborhood
      t.string :address_complement
      t.string :city
      t.string :state

      t.timestamps
    end

    add_reference :partners, :main_contact, foreign_key: { to_table: :users }
  end
end
