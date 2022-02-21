class AddFieldsToUser < ActiveRecord::Migration[6.1]
  def change
    add_reference :users, :partner
    add_column :users, :name, :string
    add_column :users, :document_type, :string
    add_column :users, :document_number, :string
    add_column :users, :iugu_customer_id, :string
  end
end
