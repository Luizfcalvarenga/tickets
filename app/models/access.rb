class Access < ApplicationRecord
  # belongs_to :event, optional: true
  # belongs_to :membership, optional: true
  belongs_to :read
  belongs_to :user
  belongs_to :granted_by, class_name: "User"
  belongs_to :pass

  scope :for_current_month, -> { where("created_at > ? and created_at < ?", Time.current.at_beginning_of_month, Time.current.at_end_of_month) }
end
