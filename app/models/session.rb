class Session < ApplicationRecord
  belongs_to :user
  belongs_to :event

  has_many :reads

  before_create :create_identifier

  def create_identifier
    self.identifier = SecureRandom.uuid
  end
end
