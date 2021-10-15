class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  include DeviseTokenAuth::Concerns::User

  has_many :qrcodes
  has_many :events, through: :qrcodes

  has_many :user_memberships
  has_many :memberships, through: :user_memberships

  belongs_to :partner, optional: true

  enum access: {
    user: "user",
    partner_user: "partner_user",
    partner_admin: "partner_admin",
    admin: "admin",
  }
end
