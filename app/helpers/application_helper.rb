module ApplicationHelper
  def display_price(price_in_cents)
    number_to_currency(price_in_cents/100, unit: "R$", separator: ",", delimiter: ".")
  end
end
