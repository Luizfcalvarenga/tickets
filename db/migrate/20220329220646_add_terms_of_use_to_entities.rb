class AddTermsOfUseToEntities < ActiveRecord::Migration[6.1]
  def change
    add_column :events, :terms_of_use, :text
    add_column :day_uses, :terms_of_use, :text
    add_column :memberships, :terms_of_use, :text
  end
end
