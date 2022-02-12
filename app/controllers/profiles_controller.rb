class ProfilesController < ApplicationController

  def edit
    @profile = current_user
  end

  def update
    @profile = current_user
    if @profile.update(profile_params)
      redirect_to dashboard_path_for_user(current_user)
    else
      render :edit
    end
  end

  private

  def profile_params
    params.require(:user).permit(:name, :photo, :document_type, :document_number)
  end
end