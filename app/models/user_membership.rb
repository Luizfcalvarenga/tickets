class UserMembership < ApplicationRecord
  belongs_to :user
  belongs_to :membership

  has_many :passes
  has_many :accesses, through: :passes

  scope :active, -> { where("iugu_active is true") }

  def create_plan_at_iugu
    self.update(iugu_active: true)
    NovaIugu::SubscriptionCreator.new(self).call
  end

  def active?
    # check_activity!
    deactivated_at.blank? && iugu_active
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
