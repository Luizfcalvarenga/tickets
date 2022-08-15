module Users
  class PasswordReseter
    attr_reader :user, :token

    def initialize(user)
      @user    = user
      @token   = nil
    end

    def call
      generate_password_token
      notify_user
    end

    private

    def generate_password_token
      @token, encrypted = Devise.token_generator.generate(User, :reset_password_token)

      user.reset_password_token = encrypted
      user.reset_password_sent_at = Time.now.utc
      user.save(validate: false)
    end

    def notify_user
      UserMailer.password_reset(user, token).deliver_now
    end
  end
end
