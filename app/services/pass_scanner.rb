class PassScanner
  attr_reader :pass, :scanner_user

  def initialize(pass, scanner_user)
    @pass = pass
    @scanner_user = scanner_user
  end
  
  def call
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
      read_by_id: scanner_user.id,
      result: @result,
      main_line: @main_line,
      secondary_line: @secondary_line
    )

    if @result
      Access.create!(
        user: @pass.user,
        granted_by_id: scanner_user.id,
        read: read,
        pass: @pass
      )
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
    if @pass.accesses.blank? && Time.current > @pass.start_time.beginning_of_day
      @result = true
      @main_line = "Acesso liberado"
      @secondary_line = ""
    elsif Time.current < @pass.start_time.beginning_of_day
      @result = false
      @main_line = "Acesso negado"
      @secondary_line = "Esse acesso só pode ser liberado no dia do evento"
    else
      @result = false
      @main_line = "Acesso negado"
      @secondary_line = "Esse passe já foi utilizado anteriormente"
    end
  end
  
  def scan_day_use_pass
    if @pass.accesses.blank? && @pass.start_time.today?
      @result = true
      @main_line = "Acesso liberado"
      @secondary_line = ""
    elsif @pass.accesses.blank? && !@pass.start_time.today?
      @result = false
      @main_line = "Acesso negado"
      @secondary_line = "Esse passe não é para hoje, mas sim para #{@pass.start_time.strftime("%d/%m/%Y")}"
    else
      @result = false
      @main_line = "Acesso negado"
      @secondary_line = "Esse passe já foi utilizado anteriormente"
    end
  end
  
  def scan_membership_pass
    if @pass.user_membership.active?
      @result = true
      @main_line = "Acesso liberado"
      @secondary_line = "O mensalista está ativo na mensalidade #{@pass.user_membership.membership.name}"
    else 
      @result = false
      @main_line = "Acesso negado"
      @secondary_line = "O mensalista não está ativo"
    end
  end
end
