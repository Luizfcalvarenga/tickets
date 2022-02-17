import React from "react";
import ReactDOM from "react-dom";
import QrScanner from "qr-scanner";
import { Scanner } from "../react_pages/Scanner";
import debounce from "lodash.debounce";

document.addEventListener("DOMContentLoaded", () => {
  const addEventListenersToDirectAccessButtons = () => {
    const accessModal = document.querySelector("#access-modal");

    if (!accessModal) return;
    
    const accessModalButtons = document.querySelectorAll(
      ".toggle-access-modal"
    );

    accessModalButtons.forEach((btn) => {
      btn.addEventListener("click", () => {
        $("#access-modal").show();

        accessModal.querySelector(
          ".modal-body"
        ).innerHTML = `<react data-component="Scanner" data-partner-slug=${btn.dataset.partnerSlug} data-pass-identifier=${btn.dataset.passIdentifier}></react>`;

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
            />,
            container
          );
        });
      });
    });
  };

  addEventListenersToDirectAccessButtons();

  const debouncedReloadList = debounce(() => {
    const tableElement = document.querySelector("#user-list");

    if (!tableElement) return;
    
    const url = `${window.location.href}?query=${queryInput.value}`;

    fetch(url, { headers: { Accept: "text/plain" } })
      .then((response) => response.text())
      .then((data) => {
        tableElement.parentNode.innerHTML = data;
        addEventListenersToDirectAccessButtons();
      });
  }, 500);

  const queryInput = document.querySelector("#query-input");
  queryInput.addEventListener("input", () => {
    debouncedReloadList();
  });

  window.addEventListener("reload-user-list", () => {
    addEventListenersToDirectAccessButtons();

    queryInput.value = "";
    debouncedReloadList();
  });
});
