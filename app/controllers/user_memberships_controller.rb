class UserMembershipsController < ApplicationController
  def create
    user_membership = UserMembership.new(create_user_membership_params)
    
    if user_membership.save 
      redirect_to dashboard_path_for_user(current_user)
    else
      raise
    end
  end

  def destroy
    user_membership = UserMembership.find(params[:id])
    
    if user_membership.destroy
      redirect_to dashboard_path_for_user(current_user)
    else
      raise
    end
  end

  private

  def create_user_membership_params
    params.require(:user_membership).permit(:membership_id).merge(user: current_user)
  end
end
