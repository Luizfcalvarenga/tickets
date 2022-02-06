module Api
  module V1
    class PassesController < ApplicationController
      skip_before_action :authenticate_user!
      
      def show
        @pass = Pass.find_by(identifier: params[:identifier])
      end

      def scan
        @pass = Pass.find_by(identifier: params[:identifier])

        if @pass.blank? 
          render json: {
            result: false,
            error: "Código não encontado",
            error_details: "Esse QR code não é válido ou não foi encontrado em nossa base"
          } and return
        end
      
        result = !@pass.event.accesses.exists?(user: @pass.user)

        @read = Read.create!(
          pass: @pass,
          result: result,
          session: @session
        )

        if result
          Access.create!(user: @pass.user, granted_by: @session.user, event: @pass.event, read: @read)

          render json: {
            result: true,
            reads: @pass.reads,
          } and return
        else
          render json: {
            result: false,
            error: "Acceso já liberado",
            error_details: "Esse QR code já foi utilizado anteriormente",
            reads: @pass.reads,
          } and return
        end
      end
    end
  end
end
