import Swal from "sweetalert2";

document.addEventListener("turbolinks:load", () => {
  if (!document.querySelector("#payment-form")) return;

  Iugu.setAccountID("7326B6B6BDA1262CD3110D783FA09B7E");
  Iugu.setTestMode(true);
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
