class UserMembership < ApplicationRecord
  belongs_to :user
  belongs_to :membership

  has_many :user_membership_renewals
  has_many :passes
  has_many :accesses, through: :passes

  scope :active, -> { where(deactivated_at: nil) }

  def create_plan_at_iugu
    self.update(iugu_active: true)
    NovaIugu::SubscriptionCreator.new(self).call
  end

  def nova_iugu_subscription_params_hash
    {
      plan_identifier: membership.identifier,
      customer_id: user.iugu_customer_id,
      only_on_charge_success: true,
    }
  end

  def check_activity!
    response = Iugu::Subscription.fetch(iugu_subscription_id)
    self.update(iugu_active: false, ended_at: Time.current) unless response.attributes["active"]
  end
end
