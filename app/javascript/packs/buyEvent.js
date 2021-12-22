document.addEventListener("turbolinks:load", () => {
  const qrcodeQuantityInput = document.querySelector("#qrcode-quantity");
  const qrcodeAnswersDiv = document.querySelector("#qrcode-answers");
  const oneQrcodeAnswerHTML = qrcodeAnswersDiv.innerHTML;

  let previousQuantityValue = parseInt(qrcodeQuantityInput.value, 10);

  const regex = /\[(\d+)\]/g

  qrcodeQuantityInput.addEventListener("change", (e) => {
    const newQuantityValue = parseInt(e.target.value, 10);

    if (newQuantityValue > previousQuantityValue) {
      qrcodeAnswersDiv.insertAdjacentHTML("beforeend", oneQrcodeAnswerHTML.replace(regex, `[${newQuantityValue - 1}]`));
    } else {
      qrcodeAnswersDiv.removeChild(qrcodeAnswersDiv.lastElementChild);
    }

    previousQuantityValue = newQuantityValue;
  });
});
