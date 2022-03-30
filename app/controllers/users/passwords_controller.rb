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
      Users::PasswordReseter.new(user).call
      flash[:notice] = "Instruções para resetar senha enviadas para seu e-mail"
      redirect_to(new_user_password_path)
    end

    # GET /resource/password/edit?reset_password_token=abcdef
    def edit
      user = User.with_reset_password_token(params[:reset_password_token])
      if user.blank?
        raise
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