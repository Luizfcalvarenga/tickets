class PassScanner
  attr_reader :pass

  def initialize(pass)
    @pass = pass
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

    read = Read.create(
      pass: @pass,
      read_by_id: User.partner_admin.last.id,
      result: @result,
      main_line: @main_line,
      secondary_line: @secondary_line
    )

    if @result
      Access.create(
        user: @pass.user,
        granted_by_id: User.partner_admin.last.id,
        read: read,
        pass: @pass
      )
    end

    {
      result: @result,
      pass_name: @pass.name,
      user_credentials: [@pass.holder_name, cpf_mask(@pass.holder_cpf)],
      main_line: @main_line,
      secondary_line: @secondary_line,
      question_list: @question_list,
      amount_paid: @pass.amount_paid,
      access_history: @pass.accesses
    }
  end

  def scan_event_pass
    if @pass.accesses.blank?
      @result = true
      @main_line = "Acesso liberado"
      @secondary_line = ""
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

  private

  def cpf_mask(cpf)
    cpf.insert(3, ".").insert(7, ".").insert(11, "-")
  end
end