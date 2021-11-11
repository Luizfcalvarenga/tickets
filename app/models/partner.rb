class Partner < ApplicationRecord
  belongs_to :main_contact, optional: true, class_name: "User"
  belongs_to :city
  belongs_to :state

  before_save :slugify

  def to_param
    slug
  end

  def slugify
    self.slug = name.parameterize if name.present?
  end

  attr_accessor :main_contact_email

  has_one_attached :logo
  
  has_many :events
  has_many :memberships
end
