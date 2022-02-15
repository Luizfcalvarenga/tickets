module Api
  module V1
    class PassesController < ApplicationController
      skip_before_action :authenticate_user!
      
      def show
        @pass = Pass.find_by(identifier: params[:identifier])
      end

      def scan
        @partner = Partner.find_by(slug: params[:partner_slug])
        @pass = @partner.passes.find_by(identifier: params[:identifier])

        if @pass.blank? 
          render json: {
            result: false,
            main_line: "Código não encontado",
            secondary_line: "Esse QR code não é válido ou não foi encontrado em nossa base"
          } and return
        end

        @pass_scanner_service = PassScanner.new(@pass)
        render json: @pass_scanner_service.call
      end
    end
  end
end
