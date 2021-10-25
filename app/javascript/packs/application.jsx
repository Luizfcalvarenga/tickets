// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
import React from "react";
import ReactDOM from "react-dom";
import "trix";
import "@rails/actiontext";

import QrScanner from "qr-scanner";
QrScanner.WORKER_PATH = `${window.location.origin}/qr-scanner-worker.js`;

import { Scanner } from "../react_pages/Scanner";
import { ReactPage } from "../react_pages/ReactPage";

import "../stylesheets/application";

Rails.start()
Turbolinks.start()
ActiveStorage.start()

// ----------------------------------------------------
// Note(lewagon): ABOVE IS RAILS DEFAULT CONFIGURATION
// WRITE YOUR OWN JS STARTING FROM HERE 👇
// ----------------------------------------------------

// External imports
import "bootstrap";

// Internal imports

const loadReactComponent = () => {
  const reactContainer = document.querySelector("react");

  if (!reactContainer || !reactContainer.dataset.component) return;

  const components = {
    Scanner: (
      <Scanner
        scanner={QrScanner}
        sessionIdentifier={reactContainer.dataset.sessionIdentifier}
        eventName={reactContainer.dataset.eventName}
      />
    ),
    ReactPage: <ReactPage message={reactContainer.dataset.message} />,
  };

  ReactDOM.render(
    components[reactContainer.dataset.component],
    reactContainer
  );
}

loadReactComponent();
