class CitiesController < ApplicationController
  protect_from_forgery except: :cities_by_state
  skip_before_action :authenticate_user!

  def cities_by_state
    @cities = City.where(state_id: params[:state_id]).order(:name)
    respond_to do |format|
      format.js { render json: @cities }
    end
  end
end
