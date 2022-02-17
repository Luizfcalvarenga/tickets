document.addEventListener("turbolinks:load", () => {
  const paymentContainer = document.querySelector(".payment-container");

  if (!paymentContainer) return;

  const orderId = paymentContainer.dataset.orderId;
  let stopPolling = false;

  if (!orderId) return;

  const poolFunction = async () => {
    if (stopPolling) return;
    const url = `/orders/${orderId}/status.json`;

    const response = await axios.get(url);

    if (response.data === "paid") {
      document.querySelector(".payment-confirmed").classList.remove("hide");
      document.querySelector(".payment-container").classList.add("hide");
      document.querySelector(".invoice").classList.add("hide");
      document.body.scrollTop = 0; // For Safari
      document.documentElement.scrollTop = 0; // For Chrome, Firefox, IE and Opera
      stopPolling = true;
    }
  };

  poolFunction();

  setInterval(poolFunction, 4000);
});
