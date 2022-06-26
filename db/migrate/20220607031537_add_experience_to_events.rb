class AddExperienceToEvents < ActiveRecord::Migration[6.1]
  def change
    add_column :events, :experience, :string
  end
end
