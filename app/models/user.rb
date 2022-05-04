class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  include DeviseTokenAuth::Concerns::User

  has_many :passes
  has_many :event_batches, through: :passes
  has_many :events, through: :event_batches

  has_many :user_memberships
  has_many :memberships, through: :user_memberships

  has_one_attached :photo
  
  belongs_to :partner, optional: true

  validate :cpf_must_be_valid
  validate :name_must_have_at_least_two_words
  validate :cep_must_be_valid

  after_create :notify_discord

  enum access: {
    user: "user",
    partner_user: "partner_user",
    partner_admin: "partner_admin",
    admin: "admin",
  }

  def name_must_have_at_least_two_words
    if name.present? && name.split.length < 2
      errors.add(:name, "deve ter pelo menos duas palavras")
    end
  end

  def cpf_must_be_valid
    if document_number.present? && !cpf_valid?(document_number)
      errors.add(:document_number, "inválido")
    end
  end

  def cep_must_be_valid
    if cep.present? && cep.gsub(/[^0-9]/, '').length != 8
      errors.add(:name, "deve ter 8 digitos numéricos")
    end
  end

  def self.to_csv
    attributes = %w[email access]
    CSV.generate(headers: true, encoding: Encoding::UTF_8) do |csv|
      csv << attributes
      all.each do |user|
          csv << user.attributes.values_at(*attributes)
          # csv << [user.email, user.access]
      end
    end
  end

  def create_customer_at_iugu
    NovaIugu::CustomerCreator.new(self).call
  end

  def nova_iugu_customer_params_hash
    {
      name: name,
      email: email
    }
  end

  def has_completed_profile?
    name.present? && document_number.present? && cep.present?
  end

  def has_payment_method?
    create_customer_at_iugu if iugu_customer_id.blank?

    Iugu::PaymentMethod.fetch({customer_id: iugu_customer_id}).results.present?
  end

  def has_membership?(membership)
    UserMembership.exists?(user: self, membership: membership, iugu_active: true)
  end

  def notify_discord
    DiscordMessager.call("Novo usuário criado: #{email}")
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
