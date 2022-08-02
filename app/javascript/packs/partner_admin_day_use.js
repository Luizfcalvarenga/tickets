import moment from "moment-strftime";

document.addEventListener("turbolinks:load", () => {
  const generatePassDateInput = document.querySelector("#generate-pass-date");
  console.log(generatePassDateInput);
  if (!generatePassDateInput) return;

  const generatePassOpenSlotsSelect = document.querySelector(
    "#generate-pass-start-time"
  );
  const generatePassPassTypeSelect = document.querySelector(
    "#generate-pass-pass-type"
  );

  generatePassDateInput.addEventListener("change", (e) => {
    if (e.target.value.length == 10 && e.target.value[0] !== "0") {
      fetch(
        `/api/v1/day_uses/${generatePassDateInput.dataset.dayUseId}?date=${e.target.value}`
      )
        .then((response) => response.json())
        .then((data) => {
          generatePassOpenSlotsSelect.innerHTML = data.open_slots_for_date
            .map((slot) => {
              return `<option value="${slot.start_time}">${moment(
                slot.start_time
              ).strftime("%H:%M")} - ${moment(slot.end_time).strftime(
                "%H:%M"
              )}</option>`;
            })
            .join();
          generatePassPassTypeSelect.innerHTML = data.pass_types
            .map((pass_type) => {
              return `<option value="${pass_type.id}">${pass_type.name}</option>`;
            })
            .join();
          if (data.open_slots_for_date.length > 0) {
            generatePassOpenSlotsSelect.disabled = false;
            generatePassPassTypeSelect.disabled = false;
          }
        });
    } else {
      generatePassOpenSlotsSelect.innerHTML = "";
      generatePassPassTypeSelect.innerHTML = "";
      generatePassOpenSlotsSelect.setAttribute("disabled", "disabled");
      generatePassPassTypeSelect.setAttribute("disabled", "disabled");
    }
  });

  document.querySelector("#user_name").addEventListener("input", (e) => {
    document.querySelector("#pre-fill-by-Nome").value = e.target.value;
  })
  document.querySelector("#user_document_number").addEventListener("input", (e) => {
    document.querySelector("#pre-fill-by-CPF").value = e.target.value;
  })
  document.querySelector("#user_cep").addEventListener("input", (e) => {
    document.querySelector("#pre-fill-by-CEP").value = e.target.value;
  })
});
