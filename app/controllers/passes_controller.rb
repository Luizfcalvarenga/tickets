class PassesController < ApplicationController
  def show
    @pass = Pass.find(params[:id])
  end
  
  def scanner
    
  end

  def create
    event = Event.find(params[:event_id])
    current_batch = event.current_batch

    raise "Ingressos esgotados" if current_batch.blank? 

    # if event_answers_params.any? { |event_param| event_param[:answer].blank? && event_param[:optional] == "false" }
    #   flash[:alert] = "Responda a todas as perguntas obrigatórias"
    #   redirect_to event_path(event) and return
    # end
    
    ActiveRecord::Base.transaction do
      (params[:event_user_answers]&.to_unsafe_h || [0]).each do |each_answer|
        pass = Pass.create(
          user: current_user,
          event: event,
          batch: current_batch,
        )

        # TODO: COLOCAR A VALIDAÇÃO DA NECESSIDADE DE RESPOSTA NO EVENTQUESTIONQRCODEANSWER, OU SEJA: 
        # CASO O EVENT_QUESTION TENHA OPTIONAL: FALSE, O EVENTQUESTIONQRCODEANSWER DEVE OBRIGATORIAMENTE TER UM VALUE

        if params[:evnt_user_answers]
          each_answer[1].each do |event_answer_params|
            EventQuestionPassAnswer.create!(
              pass: pass,
              event_question: event.event_questions.find_by(order: event_answer_params[:order]),
              value: event_answer_params[:answer],
            )
          end
        end

        if current_batch.passes.length == current_batch.quantity
          current_batch.touch(:ended_at)
        end

        svg_source = RQRCode::QRCode.new(pass.identifier).as_svg(
          color: "000",
          shape_rendering: "crispEdges",
          module_size: 5,
          standalone: true,
          use_path: true,
        )
        # TODO // Refatorar reduzindo para 1 a quantidade de consultas no db //
        pass.update(svg_source: svg_source)
      end
    end

    redirect_to dashboard_path_for_user(current_user)
  end

  private

  def event_answers_params
    params[:event_user_answers] || []
  end
end
