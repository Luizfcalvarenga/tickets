class PassConfirmationSenderJob < ApplicationJob
  queue_as :default

  def perform(pass_id)
    pass = Pass.find(pass_id)

    PassPdfBuilder.new(pass).call

    UserMailer.pass_generated(pass.user, pass).deliver_now
  end
end
