import React from "react";
import ReactDOM from "react-dom";
import QrScanner from "qr-scanner";
import { Scanner } from "../react_pages/Scanner";
import debounce from "lodash.debounce";
import Swal from "sweetalert2";

document.addEventListener("turbolinks:load", () => {
  if (!document.querySelector("#day-use-show-page")) return;

  const addEventListenersToDirectAccessButtons = () => {
    const accessModal = document.querySelector("#access-modal");

    if (!accessModal) return;

    const accessModalButtons = document.querySelectorAll(
      ".toggle-access-modal"
    );

    accessModalButtons.forEach((btn) => {
      console.log(btn)
      btn.addEventListener("click", async () => {
        const swalResult = await Swal.mixin({
          customClass: {
            confirmButton: "btn btn-success",
            cancelButton: "btn btn-danger",
          },
          buttonsStyling: false,
        }).fire({
          text: `Tem certeza que deseja liberar o acesso de ${btn.dataset.holderName}?`,
          icon: "warning",
          showCloseButton: true,
          showCancelButton: true,
          focusConfirm: false,
          confirmButtonText: "Liberar",
          cancelButtonText: "Cancelar",
        });

        if (!swalResult.isConfirmed) return;

        $("#access-modal").show();

        accessModal.querySelector(
          ".modal-body"
        ).innerHTML = `<react data-component="Scanner" data-partner-slug=${btn.dataset.partnerSlug} data-pass-identifier=${btn.dataset.passIdentifier} data-scanner-user-id=${btn.dataset.scannerUserId}></react>`;

        const reactContainers = document.querySelectorAll("react");

        if (!reactContainers) return;

        reactContainers.forEach((container) => {
          ReactDOM.render(
            <Scanner
              scanner={QrScanner}
              partnerSlug={
                container.dataset.partnerSlug
                  ? container.dataset.partnerSlug
                  : null
              }
              passIdentifier={
                container.dataset.passIdentifier
                  ? container.dataset.passIdentifier
                  : null
              }
              scannerUserId={
                container.dataset.scannerUserId
                  ? container.dataset.scannerUserId
                  : null
              }
            />,
            container
          );
        });
      });
    });
  };

  addEventListenersToDirectAccessButtons();

  const dateButtons = document.querySelectorAll(".date-card")
  let currentDate = dateButtons[0].dataset.date

  dateButtons.forEach((dateBtn) => {
    dateBtn.addEventListener("click", () => {
      currentDate = dateBtn.dataset.date;

      dateButtons.forEach((b) => b.classList.remove("selected"))
      dateBtn.classList.add("selected")

      debouncedReloadList();
    })
  })

  const debouncedReloadList = debounce(() => {
    const tableElement = document.querySelector("#user-list");
    const tableElementParentNode = document.querySelector(
      "#user-list-parent-node"
    );

    if (!tableElement) return;

    const url = `${window.location.href}?date=${currentDate}&query=${queryInput.value}`;

    fetch(url, { headers: { Accept: "text/plain" } })
      .then((response) => response.text())
      .then((data) => {
        tableElementParentNode.innerHTML = data;
        addEventListenersToDirectAccessButtons();
      });
  }, 500);

  const queryInput = document.querySelector("#query-input");
  if (!queryInput) return;

  queryInput.addEventListener("input", () => {
    debouncedReloadList();
  });

  window.addEventListener("reload-user-list", () => {
    addEventListenersToDirectAccessButtons();

    queryInput.value = "";
    debouncedReloadList();
  });
});
