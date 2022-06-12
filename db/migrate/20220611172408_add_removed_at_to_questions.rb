class AddRemovedAtToQuestions < ActiveRecord::Migration[6.1]
  def change
    add_column :questions, :removed_at, :datetime
  end
end
