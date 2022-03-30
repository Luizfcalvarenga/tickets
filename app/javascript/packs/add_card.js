import Swal from "sweetalert2";

document.addEventListener("turbolinks:load", () => {
  if (!document.querySelector("#payment-form")) return;

  Iugu.setAccountID("5A750746A17D48AF9CB0CA019AF8F272");
  // Iugu.setTestMode(true);
  // if (document.querySelector("#environment").innerHTML === "development") Iugu.setTestMode(true);

  jQuery(function ($) {
    $("#payment-form").submit(function (evt) {
      evt.preventDefault();

      var form = $(this);
      var tokenResponseHandler = function (data) {
        if (data.errors) {
          Swal.fire(
            "Erro",
            "A operadora Iugu retornou os seguintes erros ao salvar seu cartão: " + JSON.stringify(data.errors),
            "error"
          );
        } else {
          $("#token").val(data.id);
          form.get(0).submit();
        }
      };

      Iugu.createPaymentToken(this, tokenResponseHandler);
      return false;
    });
  });
});
