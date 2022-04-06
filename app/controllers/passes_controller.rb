class PassesController < ApplicationController
  def show
    @pass = Pass.find(params[:id])

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

    PassPdfBuilder.new(@pass).call unless @pass.pdf_pass.attached?

    if params[:download].present?
      send_data @pass.pdf_pass.download, filename: @pass.pdf_pass.filename.to_s, content_type: @pass.pdf_pass.content_type
    else
      redirect_to rails_blob_path(@pass.pdf_pass, disposition: 'preview')
    end
  end

  private

  def event_answers_params
    params[:event_user_answers] || []
  end
end
