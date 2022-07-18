import Inputmask from "./inputmask";

document.addEventListener("turbolinks:load", () => {
  document.querySelectorAll(".mask-cpf").forEach((input) => {
    new Inputmask("999.999.999-99").mask(input);
  })
  document.querySelectorAll(".mask-cep").forEach((input) => {
    new Inputmask("99999-999").mask(input);
  })
  document.querySelectorAll(".mask-credit-card-number").forEach((input) => {
    new Inputmask("9999999999999999").mask(input);
  });
  document.querySelectorAll(".mask-credit-card-expiration").forEach((input) => {
    new Inputmask("99/99").mask(input);
  });
});
