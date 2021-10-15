class AddFieldsToUser < ActiveRecord::Migration[6.1]
  def change
    add_reference :users, :partner
  end
end
