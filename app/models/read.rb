class Read < ApplicationRecord
  belongs_to :pass
  belongs_to :read_by, class_name: "User", foreign_key: "read_by_id"
end
