// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

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
QrScanner.WORKER_PATH = `${window.location.origin}/qr-scanner-worker.js`;

import { Scanner } from "../react_pages/Scanner";
import { ReactPage } from "../react_pages/ReactPage";
import { EventQuestions } from "../react_pages/EventQuestions";
import { EventBatches } from "../react_pages/EventBatches";
import { EventOrderItems } from "../react_pages/EventOrderItems";

import "../stylesheets/application";
import "flatpickr/dist/flatpickr.min.css";

Rails.start();
Turbolinks.start();
ActiveStorage.start();

// ----------------------------------------------------
// Note(lewagon): ABOVE IS RAILS DEFAULT CONFIGURATION
// WRITE YOUR OWN JS STARTING FROM HERE 👇
// ----------------------------------------------------

// External imports
import "bootstrap";
window.toastr = require("toastr");
window.toastr.options = {
  debug: false,
  positionClass: "toast-top-full-width toastr-position",
  fadeIn: 0,
  fadeOut: 1000,
  timeOut: 4000,
  extendedTimeOut: 1000,
};

// Internal imports
import "./events";
import "./partners";

const loadReactComponent = () => {
  const reactContainers = document.querySelectorAll("react");

  if (!reactContainers) return;

  reactContainers.forEach((container) => {
    const components = {
      Scanner: (
        <Scanner
          scanner={QrScanner}
          sessionIdentifier={container.dataset.sessionIdentifier}
          eventName={container.dataset.eventName}
        />
      ),
      ReactPage: <ReactPage message={container.dataset.message} />,
      EventQuestions: <EventQuestions />,
      EventBatches: <EventBatches />,
      EventOrderItems: (
        <EventOrderItems
          eventBatches={container.dataset.eventBatches ? JSON.parse(container.dataset.eventBatches) : null}
        />
      ),
    };

    ReactDOM.render(components[container.dataset.component], container);
  });
};

const loadToastr = () => {
  document.querySelectorAll(".flash").forEach((flash) => {
    console.log(flash);
    if (flash.dataset.type === "alert") {
      global.toastr.error(flash.dataset.message);
    } else if (flash.dataset.type === "notice") {
      global.toastr.success(flash.dataset.message);
    } else {
      return;
    }
  });
};

document.addEventListener("turbolinks:load", () => {
  loadReactComponent();
  loadToastr();
  
  flatpickr(".datetime", { dateFormat: "d-m-Y", locale: Portuguese });
});
