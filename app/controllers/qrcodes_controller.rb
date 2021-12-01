class QrcodesController < ApplicationController
  def show
    @qrcode = Qrcode.find(params[:id])
  end

  def create
    event = Event.find(params[:event_id])
    current_batch = event.current_batch

    raise "Ingressos esgotados" if current_batch.blank? 

    if event_answers_params.any? { |event_param| event_param[:answer].blank? && event_param[:optional] == "false" }
      flash[:alert] = "Responda a todas as perguntas obrigatórias"
      redirect_to event_path(event) and return
    end

    ActiveRecord::Base.transaction do
      qrcode = Qrcode.create(
        user: current_user,
        event: event,
        batch: current_batch,
      )

      event_answers_params.each do |event_answer_params|
        EventQuestionQrcodeAnswer.create!(
          qrcode: qrcode,
          event_question: event.event_questions.find_by(order: event_answer_params[:order]),
          value: event_answer_params[:answer],
        )
      end

      if current_batch.qrcodes.length == current_batch.quantity
        current_batch.touch(:ended_at)
      end

      svg_source = RQRCode::QRCode.new(qrcode.identifier).as_svg(
        color: "000",
        shape_rendering: "crispEdges",
        module_size: 5,
        standalone: true,
        use_path: true,
      )
      # TODO // Refatorar reduzindo para 1 a quantidade de consultas no db //
      qrcode.update(svg_source: svg_source)
    end

    redirect_to dashboard_path_for_user(current_user)
  end

  def read
    @qrcode = Qrcode.find(params[:id])

    result = !@qrcode.reads.exists?

    @read = Read.create(
      qrcode: @qrcode,
      result: result
    )
    @reads = @qrcode.reads
  end

  private

  def event_answers_params
    params[:event_user_answers] || []
  end
end
