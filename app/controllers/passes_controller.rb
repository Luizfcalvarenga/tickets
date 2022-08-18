class PassesController < ApplicationController
  def show
    @pass = Pass.find_by(id: params[:id])

    if @pass.blank?
      flash[:alert] = "Passe não encontrado"
      redirect_to dashboard_path_for_user(current_user) and return
    end
    if !current_user || @pass.user != current_user
      flash[:alert] = "Você não tem permissão para ver esse passe"
      redirect_to dashboard_path_for_user(current_user)
    end
  end
  
  def scanner
    @partner = current_user.partner

    respond_to do |format|
      format.html
      format.text { render layout: false }
    end
  end

  def download
    @pass = Pass.find_by(identifier: params[:identifier])

    file = PassPdfBuilder.new(@pass).call

    send_data file, filename: "Passe #{@pass.name.gsub("/", "-")} - #{@pass.holder_name}.pdf", content_type: "application/pdf"
  end

  private

  def event_answers_params
    params[:event_user_answers] || []
  end
end
