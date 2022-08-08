class DiscordMessager
  NOVAMENTE_WEBHOOK_URL = "https://discord.com/api/webhooks/959197791710756954/BaYV1XQvts0CVukiogNtsP-tdPfwl9z9zriSiKzSnvwc222W2naksXhfYFl3mJauUM2W"
  NUFLOW_WEBHOOK_URL = "https://discord.com/api/webhooks/1006153719718617211/anR2vpuSkv67MbnjJrGv9DZ0YAGKLtklpSbXjaxbrB1i16vMIiBMD_ujU1ov8nGkt6uY"

  def call(content)
    return true unless Rails.env.production?

    begin
      HTTParty.post(NOVAMENTE_WEBHOOK_URL, body: { content: content })
      HTTParty.post(NUFLOW_WEBHOOK_URL, body: { content: content })
    rescue
      false
    end
  end

  def self.call(content)
    self.new.call(content)
  end
end
