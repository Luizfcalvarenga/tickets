class MembershipsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:show, :index]
  
  def show
    @membership = Membership.find(params[:id])
    @user_membership = UserMembership.new

    if !current_user
      session[:fall_back_url] = request.url
    end
  end
end
