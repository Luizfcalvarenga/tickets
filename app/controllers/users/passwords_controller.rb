module Users
  class PasswordsController < Devise::PasswordsController
    respond_to :json


    # GET /resource/password/new
    # def new
    #   super
    # end

    # POST /resource/password
    def create
      user = User.find_by(email: email_params[:email])
      if user.present?
        Users::PasswordReseter.new(user).call
        flash[:notice] = "Instruções para resetar senha enviadas para seu e-mail"
        redirect_to(new_user_password_path) and return
      else
        flash[:alert] = "Usuário não encontrado. Verifique se digitou o e-mail corretamente"
        redirect_to(new_user_password_path) and return
      end
    end

    # GET /resource/password/edit?reset_password_token=abcdef
    def edit
      user = User.with_reset_password_token(params[:reset_password_token])
      if user.blank?
        flash[:error] = t(".link_expired")
        redirect_to(new_user_password_path)
        return
      end
      super
    end

    # PUT /resource/password
    # def update
    #   super
    # end

    protected

    def email_params
      params.require(:user).permit(:email)
    end

    # The path used after sending reset password instructions
    # def after_sending_reset_password_instructions_path_for(resource_name)
    #   super(resource_name)
    # end
  end
end
