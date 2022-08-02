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

window.mobileMode = function () {
  let check = false;
  (function (a) {
    if (
      /(android|bb\d+|meego).+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|mobile.+firefox|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\.(browser|link)|vodafone|wap|windows ce|xda|xiino/i.test(
        a
      ) ||
      /1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\-|your|zeto|zte\-/i.test(
        a.substr(0, 4)
      )
    )
      check = true;
  })(navigator.userAgent || navigator.vendor || window.opera);
  return check;
};

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
import "./file_upload";
import "./forms";
import "./partner_admin_day_use";
import "./address_cep";
import "./event_user_list";
import "./day_use_user_list";
import "./membership_user_list";
import "./partners";
import "./payment_pooling";
import "./masks";

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
          scannerUserId={
            container.dataset.scannerUserId
              ? container.dataset.scannerUserId
              : null
          }
        />
      ),
      ReactPage: <ReactPage message={container.dataset.message} />,
      Questions: (
        <Questions
          questions={
            container.dataset.questions
              ? JSON.parse(container.dataset.questions)
              : null
          }
          errors={
            container.dataset.errors
              ? JSON.parse(container.dataset.errors)
              : null
          }
        />
      ),
      EventBatches: (
        <EventBatches
          event={
            container.dataset.event ? JSON.parse(container.dataset.event) : null
          }
          eventBatches={
            container.dataset.eventBatches ? JSON.parse(container.dataset.eventBatches) : null
          }
          errors={
            container.dataset.errors ? JSON.parse(container.dataset.errors) : null
          }
        />
      ),

      DayUseSchedules: (
        <DayUseSchedules
          dayUseSchedules={
            container.dataset.dayUseSchedules
              ? JSON.parse(container.dataset.dayUseSchedules)
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

  const password_signin = document.getElementById("password_signin");
  const password_signup = document.getElementById("password_signup");
  const password_confirmation = document.getElementById(
    "password_confirmation"
  );
  const togglePasswordSignin = document.getElementById(
    "toggle-password-signin"
  );
  const togglePasswordSignup = document.getElementById(
    "toggle-password-signup"
  );

  function toggleClickedSignIn() {
    if (this.checked) {
      password_signin.type = "text";
    } else {
      password_signin.type = "password";
    }
  }

  function toggleClickedSignUp() {
    if (this.checked) {
      password_confirmation.type = "text";
      password_signup.type = "text";
    } else {
      password_confirmation.type = "password";
      password_signup.type = "password";
    }
  }

  if (togglePasswordSignin)
    togglePasswordSignin.addEventListener("click", toggleClickedSignIn);
  if (togglePasswordSignup)
    togglePasswordSignup.addEventListener("click", toggleClickedSignUp);
});
