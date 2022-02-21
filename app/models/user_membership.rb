class UserMembership < ApplicationRecord
  belongs_to :user
  belongs_to :membership

  scope :active, -> { where("iugu_active is true") }

  after_create :create_plan_at_iugu

  def create_plan_at_iugu
    NovaIugu::SubscriptionCreator.new(self).call
  end

  def active?
    check_activity!
    iugu_active
  end

  def nova_iugu_subscription_params_hash
    {
      plan_identifier: membership.identifier,
      customer_id: user.iugu_customer_id,
    }
  end

  def check_activity!
    response = Iugu::Subscription.fetch(iugu_subscription_id)
    self.update(iugu_active: false, ended_at: Time.current) unless response.attributes["active"]
  end
end
