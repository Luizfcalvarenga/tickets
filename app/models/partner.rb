class Partner < ApplicationRecord
  belongs_to :main_contact, optional: true, class_name: "User"
  belongs_to :city
  belongs_to :state

  has_many :memberships

  before_create :slugify

  scope :active, -> { where(active: true) }

  enum kind: {
    bike_park: "bike_park",
    organizer: "organizer",
  }

  def to_param
    slug
  end

  def slugify
    self.slug = name.parameterize if name.present?
  end

  attr_accessor :main_contact_email

  has_one_attached :logo
  has_one_attached :banner
  
  has_many :passes
  has_many :events
  has_many :memberships
  has_many :user_memberships, through: :memberships
  has_many :day_uses

  validates :slug, uniqueness: true

  def memberships_csv
    users = User.joins(passes: [user_membership: :membership]).where(memberships: {id: memberships.ids}).group("users.id").order("users.name")

    attributes = ["Email do usuário", "Nome", "CPF", "Mensalidades ativas"]
    CSV.generate(headers: true) do |csv|
      csv << attributes
      users.each do |user|
        csv << [user.email, user.name, user.document_number, user.user_memberships.active.where(user_memberships: {membership_id: memberships.ids}).map { |um| um.membership.name }.join(", ")]
      end
    end
  end
end
