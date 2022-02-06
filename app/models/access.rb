class Access < ApplicationRecord
  # belongs_to :event, optional: true
  # belongs_to :membership, optional: true
  belongs_to :read
  belongs_to :user
  belongs_to :granted_by, class_name: "User"
  belongs_to :pass
end
