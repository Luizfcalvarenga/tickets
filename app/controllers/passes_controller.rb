class PassesController < ApplicationController
  def show
    @pass = Pass.find(params[:id])
  end
  
  def scanner
    @partner = current_user.partner

    respond_to do |format|
      format.html
      format.text { render layout: false }
    end
  end

  private

  def event_answers_params
    params[:event_user_answers] || []
  end
end
