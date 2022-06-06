class AddPixFieldsToOrder < ActiveRecord::Migration[6.1]
  def change
    add_column :orders, :invoice_pix_qrcode_url, :string
    add_column :orders, :invoice_pix_qrcode_text, :string
  end
end
