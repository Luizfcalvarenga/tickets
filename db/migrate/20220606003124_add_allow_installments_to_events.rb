class AddAllowInstallmentsToEvents < ActiveRecord::Migration[6.1]
  def change
    add_column :events, :allow_installments, :boolean, default: :false
  end
end
