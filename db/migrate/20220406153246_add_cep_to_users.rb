class AddCepToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :cep, :string
  end
end
