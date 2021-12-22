class AddFieldsToUser < ActiveRecord::Migration[6.1]
  def change
    add_reference :users, :partner
    add_column :users, :name, :string
  end
end
