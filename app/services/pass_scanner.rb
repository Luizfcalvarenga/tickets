class PassScanner
  MAXIMUM_RECENT_RESTORE_TIME_IN_SECONDS = 10

  attr_reader :pass, :scanner_user

  def initialize(pass, scanner_user)
    @pass = pass
    @scanner_user = scanner_user
  end
  
  def call
    restore_recent_read = Read.where("created_at > ?", MAXIMUM_RECENT_RESTORE_TIME_IN_SECONDS.seconds.ago).where(pass: @pass, read_by: scanner_user).first

    if restore_recent_read
      @result = restore_recent_read.result
      @main_line = restore_recent_read.main_line
      @secondary_line = restore_recent_read.secondary_line
    else
      case @pass.kind
      when "event"
        scan_event_pass
      when "day_use"
        scan_day_use_pass
      when "membership"
        scan_membership_pass
      else
        raise
      end
  
      read = Read.create!(
        pass: @pass,
        read_by: scanner_user,
        result: @result,
        main_line: @main_line,
        secondary_line: @secondary_line
      )

      if @result
        Access.create!(
          user: @pass.user,
          granted_by: scanner_user,
          read: read,
          pass: @pass
        )
      end
    end

    @question_list = @pass.question_answers.map do |question_answers|
      question_answers.as_json(include: :question)
    end

    @accesses = @pass.accesses.map do |access|
      access.as_json(include: :granted_by)
    end

    {
      result: @result,
      pass_name: @pass.name,
      user_credentials: [@pass.holder_name, @pass.holder_cpf],
      main_line: @main_line,
      secondary_line: @secondary_line,
      question_list: @question_list,
      pass_generated_at: @pass.created_at.strftime("%d/%m/%Y - %H:%M"),
      price_in_cents: @pass.price_in_cents,
      access_history: @accesses
    }
  end

  def scan_event_pass
    if @pass.accesses.count < @pass.event_batch.number_of_accesses_granted
      @result = true
      @main_line = "Acesso liberado"
      @secondary_line = ""
    elsif @pass.accesses.count >= @pass.event_batch.number_of_accesses_granted
      @result = false
      @main_line = "Acesso negado"
      @secondary_line = "Esse passe já foi utilizado o limite de #{@pass.event_batch.number_of_accesses_granted} vez(es)"
    # elsif Time.current < @pass.start_time.beginning_of_day
    #   @result = false
    #   @main_line = "Acesso negado"
    #   @secondary_line = "Esse acesso só pode ser liberado no dia do evento"
    else
      @result = false
      @main_line = "Acesso negado"
      @secondary_line = "Esse passe já foi utilizado anteriormente"
    end
  end
  
  def scan_day_use_pass
    if @pass.accesses.count < @pass.day_use_schedule_pass_type.number_of_accesses_granted
      @result = true
      @main_line = "Acesso liberado"
      @secondary_line = ""
    else @pass.accesses.count >= @pass.day_use_schedule_pass_type.number_of_accesses_granted
      @result = false
      @main_line = "Acesso negado"
      @secondary_line = "Esse passe já foi utilizado o limite de #{@pass.day_use_schedule_pass_type.number_of_accesses_granted} vez(es)"
    end
  end
  
  def scan_membership_pass
    if @pass.user_membership.active? && @pass.accesses.for_current_month.count < @pass.user_membership.membership.monthly_pass_usage_limit
      @result = true
      @main_line = "Acesso liberado"
      @secondary_line = "O mensalista está ativo na mensalidade #{@pass.user_membership.membership.name}"
    elsif @pass.user_membership.active? && @pass.accesses.for_current_month.count >= @pass.user_membership.membership.monthly_pass_usage_limit
      @result = false
      @main_line = "Acesso negado"
      @secondary_line = "O mensalista já utilizou o limite de #{@pass.user_membership.membership.monthly_pass_usage_limit} acessos para o mês"
    else
      @result = false
      @main_line = "Acesso negado"
      @secondary_line = "O mensalista não está ativo"
    end
  end
end
