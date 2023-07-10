require "open-uri"

class UserMailer < ApplicationMailer
  include Devise::Controllers::UrlHelpers
  default from: 'NuflowPass <mail@nuflow.com.br>'

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

  def pass_generated(user, pass)
    @user = user
    @pass = pass

    mail(to: @user.email, subject: "Seu passe #{pass.name} foi gerado!")
  end
end
