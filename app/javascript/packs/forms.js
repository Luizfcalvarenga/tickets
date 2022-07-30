document.addEventListener("turbolinks:load", () => {
  document.querySelectorAll("form").forEach((form) => {
    form.addEventListener("submit", () => {
      const submitButton = form.querySelector("[type=submit]");
      const originalSubmitButtonText = submitButton.innerText;
      submitButton.setAttribute("disabled", "disabled");
      submitButton.innerText = "Enviando...";
      setTimeout(() => {
        submitButton.removeAttribute("disabled");
        submitButton.innerText = originalSubmitButtonText;
      }, 10000)
    });
  });
});
