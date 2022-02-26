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

import { Scanner } from "../react_pages/Scanner";
import { ReactPage } from "../react_pages/ReactPage";
import { Questions } from "../react_pages/Questions";
import { EventBatches } from "../react_pages/EventBatches";
import { EventOrderItems } from "../react_pages/EventOrderItems";
import { DayUseOrderItems } from "../react_pages/DayUseOrderItems";
import { DayUseSchedules } from "../react_pages/DayUseSchedules";

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
import "./add_card";
import "./events";
import "./event_user_list";
import "./day_use_user_list";
import "./membership_user_list";
import "./partners";
import "./payment_pooling";

const loadReactComponent = () => {
  const reactContainers = document.querySelectorAll("react");

  if (!reactContainers) return;

  reactContainers.forEach((container) => {
    const components = {
      Scanner: (
        <Scanner
          scanner={QrScanner}
          partnerSlug={container.dataset.partnerSlug}
          passIdentifier={
            container.dataset.passIdentifier
              ? JSON.parse(container.dataset.passIdentifier)
              : null
          }
        />
      ),
      ReactPage: <ReactPage message={container.dataset.message} />,
      Questions: <Questions />,
      EventBatches: <EventBatches />,

      DayUseSchedules: (
        <DayUseSchedules
          weekdays={
            container.dataset.weekdays
              ? JSON.parse(container.dataset.weekdays)
              : null
          }
        />
      ),

      EventOrderItems: (
        <EventOrderItems
          event={
            container.dataset.event ? JSON.parse(container.dataset.event) : null
          }
          eventBatches={
            container.dataset.eventBatches
              ? JSON.parse(container.dataset.eventBatches)
              : null
          }
          feePercentage={
            container.dataset.feePercentage
              ? JSON.parse(container.dataset.feePercentage)
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
          openSlots={
            container.dataset.openSlots
              ? JSON.parse(container.dataset.openSlots)
              : null
          }
          passTypes={
            container.dataset.passTypes
              ? JSON.parse(container.dataset.passTypes)
              : null
          }
          date={
            container.dataset.date ? JSON.parse(container.dataset.date) : null
          }
          feePercentage={
            container.dataset.feePercentage
              ? JSON.parse(container.dataset.feePercentage)
              : null
          }
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

const fillInputs = () => {
  document.querySelectorAll("textarea").forEach((textarea) => {
    textarea.innerHTML = textarea.dataset.fillInnerHtml || "";
  });
  document.querySelectorAll("input").forEach((input) => {
    if (input.value || !input.dataset.fillInnerHtml) return;
    
    input.value = input.dataset.fillInnerHtml || "";
  });
};

document.addEventListener("turbolinks:load", () => {
  loadReactComponent();
  loadToastr();
  fillInputs();

  // Platform events
  window.reloadUserEvent = new Event("reload-user-list");

  flatpickr(".datetime", { dateFormat: "d-m-Y", locale: Portuguese });
});
