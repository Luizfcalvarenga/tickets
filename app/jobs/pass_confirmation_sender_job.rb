class PassConfirmationSenderJob < ApplicationJob
  queue_as :default

  def perform(pass_id)
    pass = Pass.find(pass_id)

    # PassPdfBuilder.new(pass).call TODO: The pass is not being generated on the email at the moment. See if we need to generate it again and send as an attachment on email

    UserMailer.pass_generated(pass.user, pass).deliver_now
  end
end
