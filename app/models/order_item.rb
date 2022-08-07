class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :partner, optional: true
  belongs_to :event_batch, optional: true
  belongs_to :day_use_schedule_pass_type, optional: true
  belongs_to :user_membership_renewal, optional: true
  
  has_one :pass, dependent: :destroy
  has_one :coupon_order_item
  has_one :coupon, through: :coupon_order_item

  has_many :question_answers, dependent: :destroy

  def related_entity
    if day_use_schedule_pass_type.present?
      day_use_schedule_pass_type.day_use
    elsif event_batch.present?
      event_batch.event
    elsif user_membership_renewal.present?
      user_membership_renewal.user_membership.membership
    else 
      raise
    end
  end

  def total_in_cents
    (price_with_discount_in_cents * (absorb_fee ? 1 : 1 + (fee_percentage / 100))).to_i
  end

  def price_with_discount_in_cents
    price_in_cents - discount_value_in_cents
  end

  def discount_value_in_cents
    return price_in_cents if order.directly_generated_by_id.present?
    
    return 0 if coupon.blank?

    value = coupon.percentage? ? (price_in_cents * coupon.discount / 100) : coupon.discount

    return value >= price_in_cents ? price_in_cents : value
  end

  def amount_to_transfer_to_partner
    total_in_cents - platform_fee_value_in_cents
  end

  def platform_fee_value_in_cents
    # Effective value of platform fees for internal uses and display for partner
    (price_with_discount_in_cents * fee_percentage / 100).round
  end

  def displayed_fee_value_in_cents
    # Value displayed to final user in platform fees
    absorb_fee ? 0 : price_with_discount_in_cents * fee_percentage / 100
  end

  def identification_name
    return nil if question_answers.blank?

    question_answers.joins(:question).find_by(questions: {prompt: "Nome completo"}).value
  end

  def identification_cpf
    return nil if question_answers.blank?

    cpf = question_answers.joins(:question).find_by(questions: {prompt: "CPF"}).value

    cpf.insert(3, ".").insert(7, ".").insert(11, "-")
  end

  def full_description
    if event_batch.present?
      return "#{event_batch.event.name} - #{event_batch.pass_type} - #{event_batch.name}"
    elsif day_use_schedule_pass_type.present?
      return "#{day_use_schedule_pass_type.day_use_schedule.day_use.name} - #{day_use_schedule_pass_type.day_use_schedule.name} - #{day_use_schedule_pass_type.name} - #{start_time.strftime("%d/%m/%Y")} - #{start_time.strftime("%H:%M")} - #{end_time.strftime("%H:%M")}"
    elsif user_membership_renewal.present?
      return "Renovação da assinatura #{user_membership_renewal.user_membership.membership.name} - #{user_membership_renewal.renewal_date.strftime("%d/%m/%Y")}"
    else
      raise RecordInvalid
    end
  end

  def questions
    if event_batch.present?
      event_batch.event.questions.order(:created_at)
    elsif day_use_schedule_pass_type.present?
      day_use_schedule_pass_type.day_use_schedule.day_use.questions.order(:created_at)
    else
      raise
    end
  end
end
