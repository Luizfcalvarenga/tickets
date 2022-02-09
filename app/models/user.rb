class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  include DeviseTokenAuth::Concerns::User

  has_many :passes
  has_many :event_batches, through: :passes
  has_many :events, through: :event_batches

  has_many :user_memberships
  has_many :memberships, through: :user_memberships

  has_one_attached :photo
  
  belongs_to :partner, optional: true

  enum access: {
    user: "user",
    partner_user: "partner_user",
    partner_admin: "partner_admin",
    admin: "admin",
  }

  def self.to_csv
    attributes = %w[email access]
    CSV.generate(headers: true) do |csv|
      csv << attributes
      all.each do |user|
          csv << user.attributes.values_at(*attributes)
          # csv << [user.email, user.access]
      end
    end
  end
end
