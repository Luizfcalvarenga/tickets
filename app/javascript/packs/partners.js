import Inputmask from "./inputmask";

document.addEventListener("turbolinks:load", () => {
  if (!document.querySelector("partner-form")) return;

  new Inputmask("(99) 99999-9999").mask(
    document.getElementById("partner_contact_phone_1")
  );
  new Inputmask("(99) 99999-9999").mask(
    document.getElementById("partner_contact_phone_2")
  );
  new Inputmask("99.999.999/0001-99").mask(
    document.getElementById("partner_cnpj")
  );
});
