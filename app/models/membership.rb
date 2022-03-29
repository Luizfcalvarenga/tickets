class Membership < ApplicationRecord
  belongs_to :partner
  belongs_to :approved_by, class_name: "User", foreign_key: "approved_by_id", optional: true

  has_many :user_memberships
  has_many :users, through: :user_memberships

  has_rich_text :description
  has_rich_text :short_description

  validates :name, presence: true, uniqueness: { scope: :partner_id }

  after_create :create_plan_at_iugu

  scope :not_approved, -> { where(approved_at: nil) }

  def identifier
    "nuflowpass-#{partner.id}-#{id}"
  end

  def nova_iugu_plan_params_hash
    {
      name: name,
      identifier: identifier,
      interval: 1,
      interval_type: "months",
      value_cents: price_in_cents,
      payable_with: "credit_card",
      billing_days: 7,
    }
  end

  def create_plan_at_iugu
    NovaIugu::PlanCreator.new(self).call
  end
end
