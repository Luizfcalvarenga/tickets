class ProfilesController < ApplicationController

  def edit
    @profile = current_user
  end

  def update
    @profile = current_user
    if @profile.update(profile_params)
      flash[:notice] = "Informações atualizadas com sucesso"
    
      redirect_to_return_url_if_one_is_provided and return

      redirect_to dashboard_path_for_user(current_user)
    else
      flash[:alert] = "Ocorreu algum erro ao atualizar seus dados. Insira o nome completo, CPF, telefone e CEP válidos"
      redirect_to dashboard_path_for_user(current_user, current_tab: "nav-acc-info", return_url: request.referrer) and return
    end
  end

  private

  def profile_params
    params.require(:user).permit(:name, :photo, :document_number, :cep, :phone_number)
  end
end
