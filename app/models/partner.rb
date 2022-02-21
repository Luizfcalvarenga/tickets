class Partner < ApplicationRecord
  belongs_to :main_contact, optional: true, class_name: "User"
  belongs_to :city
  belongs_to :state

  before_create :slugify

  def to_param
    slug
  end

  def slugify
    self.slug = name.parameterize if name.present?
  end

  attr_accessor :main_contact_email

  has_one_attached :logo
  
  has_many :passes
  has_many :events
  has_many :memberships
  has_many :user_memberships, through: :memberships
  has_many :day_uses
end
