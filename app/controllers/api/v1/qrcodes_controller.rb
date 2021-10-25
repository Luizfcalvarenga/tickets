module Api
  module V1
    class QrcodesController < ApplicationController
      skip_before_action :authenticate_user!
      
      def show
        @qrcode = Qrcode.find_by(identifier: params[:identifier])
      end

      def scan
        @qrcode = Qrcode.find_by(identifier: params[:identifier])

        if @qrcode.blank? 
          render json: {
            result: false,
            error: "Código não encontado",
            error_details: "Esse QR code não é válido ou não foi encontrado em nossa base"
          } and return
        end

        @session = Session.find_by(identifier: params[:session_identifier])

        if @session.blank? 
          render json: {
            result: false,
            error: "Sessão não inicializada",
            error_details: "Você deve iniciar uma sessão de Scan no seu dashboard"
          } and return
        end
        
        if @session.event != @qrcode.event 
          render json: {
            result: false,
            error: "Evento inválido",
            error_details: "O QR code é referente ao evento #{@qrcode.event.name}"
          } and return
        end

        result = !@qrcode.event.accesses.exists?(user: @qrcode.user)

        @read = Read.create!(
          qrcode: @qrcode,
          result: result,
          session: @session
        )

        if result
          Access.create!(user: @qrcode.user, granted_by: @session.user, event: @qrcode.event, read: @read)

          render json: {
            result: result,
            reads: @qrcode.reads,
          } and return
        else
          render json: {
            result: result,
            error: "Acceso já liberado",
            error_details: "Esse QR code já foi utilizado anteriormente",
            reads: @qrcode.reads,
          } and return
        end
      end
    end
  end
end
