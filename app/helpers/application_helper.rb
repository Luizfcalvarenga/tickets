module ApplicationHelper
  def display_price(price_in_cents)
    number_to_currency(price_in_cents/100, unit: "R$", separator: ",", delimiter: ".")
  end

  def cpf_mask(cpf)
    cpf.insert(3, ".").insert(7, ".").insert(11, "-")
  end
end
