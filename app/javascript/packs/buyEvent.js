document.addEventListener("turbolinks:load", () => {
  const passQuantityInput = document.querySelector("#pass-quantity");
  const passAnswersDiv = document.querySelector("#pass-answers");
  const oneQrcodeAnswerHTML = passAnswersDiv.innerHTML;

  let previousQuantityValue = parseInt(passQuantityInput.value, 10);

  const regex = /\[(\d+)\]/g

  passQuantityInput.addEventListener("change", (e) => {
    const newQuantityValue = parseInt(e.target.value, 10);

    if (newQuantityValue > previousQuantityValue) {
      passAnswersDiv.insertAdjacentHTML("beforeend", oneQrcodeAnswerHTML.replace(regex, `[${newQuantityValue - 1}]`));
    } else {
      passAnswersDiv.removeChild(passAnswersDiv.lastElementChild);
    }

    previousQuantityValue = newQuantityValue;
  });
});
