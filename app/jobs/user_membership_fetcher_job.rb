class UserMembershipFetcherJob < ApplicationJob
  queue_as :default

  def perform(user_membership)
    subscription = Iugu::Subscription.fetch(user_membership.iugu_subscription_id)

    user_membership.update(iugu_active: false) if user_membership.deactivated_at.present?

    if subscription.attributes["suspended"] && Date.parse(subscription.attributes["expires_at"]).end_of_day < Time.current && user_membership.deactivated_at.blank?
      user_membership.update(deactivated_at: Time.current, iugu_active: false)
      user_membership.passes.update_all(deactivated_at: Time.current)
    end

    subscription.attributes["recent_invoices"].each do |recent_invoice|
      order = Order.find_by(invoice_id: recent_invoice["id"])

      if order.blank?
        ActiveRecord::Base.transaction do
          user_membership_renewal = UserMembershipRenewal.create!(user_membership: user_membership, 
            renewal_date: Date.parse(recent_invoice["due_date"]))
          order = Order.create!(user: user_membership.user, invoice_id: recent_invoice["id"], invoice_status: "pending")
          order_item = OrderItem.create!(order: order,
            user_membership_renewal: user_membership_renewal,
            price_in_cents: user_membership_renewal.membership.price_in_cents,
            fee_percentage: user_membership_renewal.membership.fee_percentage,
            partner: user_membership_renewal.membership.partner,
            absorb_fee: true
          )
          ::NovaIugu::ChargeCheckAndUpdateStatus.new(order).call
        end
      end
    end

  rescue Iugu::ObjectNotFound
    false
  end
end
