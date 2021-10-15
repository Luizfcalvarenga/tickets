class Qrcode < ApplicationRecord
  belongs_to :user
  belongs_to :event, optional: true
  belongs_to :membership, optional: true
  belongs_to :batch, optional: true

  before_create :create_identifier

  has_many :reads

  def create_identifier
    self.identifier = SecureRandom.uuid
  end
end
