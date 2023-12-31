class QuestionAnswer < ApplicationRecord
  belongs_to :question
  belongs_to :order_item

  validates :value, presence: true, unless: :question_is_optional
  validate :must_have_at_least_two_names_on_full_name_question
  validate :must_be_a_valid_cpf_on_cpf_question
  validate :must_be_a_valid_cep_on_cep_question

  before_validation :sanitize_value

  scope :default_questions, -> { joins(:question).where(questions: { default: true }) }
  scope :default_questions, -> { joins(:question).where.not(questions: { default: true }) }

  def sanitize_value
    if ["CPF", "CEP"].include?(question.prompt)
      self.value = value.gsub(/[^0-9A-Za-z]/, '')
    end
  end

  def question_is_optional
    question.optional
  end

  def must_have_at_least_two_names_on_full_name_question
    if question.prompt == "Nome completo" and value.split.length < 2
      errors.add(:value, "Nome completo deve ter pelo menos dois nomes")
    end
  end

  def must_be_a_valid_cpf_on_cpf_question
    if question.prompt == "CPF" && !cpf_valid?(value)
      errors.add(:value, "CPF inválido")
    end
  end

  def must_be_a_valid_cep_on_cep_question
    return true unless question.prompt == "CEP"

    if !(/^\d{8}$/.match?(value))
      errors.add(:value, "CEP inválido, deve conter 8 digitos numéricos")
    end
  end

  def cpf_valid?(cpf)
    return false if cpf.nil?
  
    nulos = %w{12345678909 11111111111 22222222222 33333333333 44444444444 55555555555 66666666666 77777777777 88888888888 99999999999 00000000000 12345678909}
    valor = cpf.scan /[0-9]/
    if valor.length == 11
      unless nulos.member?(valor.join)
        valor = valor.collect{|x| x.to_i}
        soma = 10*valor[0]+9*valor[1]+8*valor[2]+7*valor[3]+6*valor[4]+5*valor[5]+4*valor[6]+3*valor[7]+2*valor[8]
        soma = soma - (11 * (soma/11))
        resultado1 = (soma == 0 or soma == 1) ? 0 : 11 - soma
        if resultado1 == valor[9]
          soma = valor[0]*11+valor[1]*10+valor[2]*9+valor[3]*8+valor[4]*7+valor[5]*6+valor[6]*5+valor[7]*4+valor[8]*3+valor[9]*2
          soma = soma - (11 * (soma/11))
          resultado2 = (soma == 0 or soma == 1) ? 0 : 11 - soma
          return true if resultado2 == valor[10]
        end
      end
    end
    return false
  end
end
