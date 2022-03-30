class UserMailer < ApplicationMailer
  include Devise::Controllers::UrlHelpers
  default from: 'NuflowPass <naoresponda@nuflowpass.com.br>'

  def welcome(user, token)
    @user = user
    @token = token
    mail(to: @user.email, subject: 'Seja bem-vindo(a) à NuflowPass')
  end

  def password_reset(user, token)
    @user = user
    @token = token
    mail(to: @user.email, subject: 'Recuperação de senha do NuflowPass')
  end
end