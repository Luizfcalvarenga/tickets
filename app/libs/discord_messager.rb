class DiscordMessager
  WEBHOOK_URL = "https://discord.com/api/webhooks/959197791710756954/BaYV1XQvts0CVukiogNtsP-tdPfwl9z9zriSiKzSnvwc222W2naksXhfYFl3mJauUM2W"

  def call(content)
    return true unless Rails.env.production?

    begin
      HTTParty.post(WEBHOOK_URL, body: { content: content })
    rescue
      false
    end
  end

  def self.call(content)
    self.new.call(content)
  end
end
