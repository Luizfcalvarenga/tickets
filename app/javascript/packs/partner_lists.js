import Rails from "@rails/ujs";
import Turbolinks from "turbolinks";
import * as ActiveStorage from "@rails/activestorage";
import React from "react";
import ReactDOM from "react-dom";
import "trix";
import "@rails/actiontext";
import flatpickr from "flatpickr";
import { Portuguese } from "flatpickr/dist/l10n/pt.js";

import QrScanner from "qr-scanner";

import { Scanner } from "../react_pages/Scanner";
import { ReactPage } from "../react_pages/ReactPage";
import { EventQuestions } from "../react_pages/EventQuestions";
import { EventBatches } from "../react_pages/EventBatches";
import { EventOrderItems } from "../react_pages/EventOrderItems";
import { DayUseOrderItems } from "../react_pages/DayUseOrderItems";

import "../stylesheets/application";
import "flatpickr/dist/flatpickr.min.css";

document.addEventListener("DOMContentLoaded", () => {
  const accessModal = document.querySelector("#access-modal");

  const accessModalButtons = document.querySelectorAll(".toggle-access-modal");

  accessModalButtons.forEach((btn) => {
    btn.addEventListener("click", () => {
      $("#access-modal").show();

      accessModal.querySelector(
        ".modal-body"
      ).innerHTML = `<react data-component="Scanner" data-partner-slug=${btn.dataset.partnerSlug} data-pass-identifier=${btn.dataset.passIdentifier}></react>`;

      const reactContainers = document.querySelectorAll("react");

      if (!reactContainers) return;

      reactContainers.forEach((container) => {
        const components = {
          Scanner: (
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
            />
          ),
          ReactPage: <ReactPage message={container.dataset.message} />,
          EventQuestions: <EventQuestions />,
          EventBatches: <EventBatches />,
          EventOrderItems: (
            <EventOrderItems
              event={
                container.dataset.event
                  ? JSON.parse(container.dataset.event)
                  : null
              }
              eventBatches={
                container.dataset.eventBatches
                  ? JSON.parse(container.dataset.eventBatches)
                  : null
              }
            />
          ),
          DayUseOrderItems: (
            <DayUseOrderItems
              dayUse={
                container.dataset.dayUse
                  ? JSON.parse(container.dataset.dayUse)
                  : null
              }
              dayUseSchedule={
                container.dataset.dayUseSchedule
                  ? JSON.parse(container.dataset.dayUseSchedule)
                  : null
              }
              date={
                container.dataset.date
                  ? JSON.parse(container.dataset.date)
                  : null
              }
            />
          ),
        };

        ReactDOM.render(components[container.dataset.component], container);
      });
    });
  });

  const loadScannerElement = async () => {};

  loadScannerElement();
});
