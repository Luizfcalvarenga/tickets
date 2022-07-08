class PaymentCheckerJob < ApplicationJob
  queue_as :default

  def perform
    Order.where("created_at > ?", Time.current - 7.day).where(invoice_status: "pending").each do |order|
      ::NovaIugu::ChargeCheckAndUpdateStatus.new(order).call
    end
  end
end
