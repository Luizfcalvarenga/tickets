class Membership < ApplicationRecord
  belongs_to :partner
  belongs_to :approved_by, class_name: "User", foreign_key: "approved_by_id", optional: true

  has_many :user_memberships
  has_many :users, through: :user_memberships

  has_rich_text :description
  has_rich_text :short_description
  has_rich_text :terms_of_use

  validates :name, presence: true, uniqueness: { scope: :partner_id }

  after_create :create_plan_at_iugu

  scope :not_approved, -> { where(approved_at: nil, deactivated_at: nil) }
  scope :active, -> { where.not(approved_at: nil).where(deactivated_at: nil) }
  scope :deactivated, -> { where.not(deactivated_at: nil) }

  def identifier
    "nuflowpass-#{partner.id}-#{id}"
  end

  def nova_iugu_plan_params_hash
    {
      name: name,
      identifier: identifier,
      interval: recurrence_interval_in_months,
      interval_type: "months",
      value_cents: price_in_cents,
      payable_with: "credit_card",
      billing_days: 7,
    }
  end

  def create_plan_at_iugu
    NovaIugu::PlanCreator.new(self).call
  end

  def full_address
    "#{partner.street_name} - #{partner.street_number} - #{partner.address_complement}, #{partner.neighborhood}, #{partner.city.name} - #{partner.city.state.acronym}"
  end
end
