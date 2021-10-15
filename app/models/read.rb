class Read < ApplicationRecord
  belongs_to :qrcode
  belongs_to :session
end
