import "uswds/dist/css/uswds.css";
import "uswds/dist/js/uswds.js";

// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import jquery from  "jquery";
import "popper.js";
import "bootstrap/dist/css/bootstrap.css";
import "bootstrap/dist/js/bootstrap.js";
import "select2";

import "quill/dist/quill.core.css";
import "quill/dist/quill.snow.css";

// Phoenix html dependency
import "phoenix_html"

import "admin-lte/dist/css/adminlte.css";
import "admin-lte/dist/js/adminlte.js";
import "@fortawesome/fontawesome-free/css/all.css";

// Custom CSS
require("../css/app.scss");
import "../css/progress_bar.scss";

// Custom JS
import "./custom_select.js";
import "./dynamic_nested_fields.js";
import "./radio_button_show.js";
import "./character_limit.js";
import "./datetime_field.js";
import "./custom_url_generator.js";
import "./section_file_upload.js";
import "./solution_file_upload.js";
import "./remove_reports_error.js";
import "./rich_text_editor.js";

// Wizard specific JS
import "./challenge_wizard_rules.js";


$(".wrapper").prepend(
  `<div id="renew-modal" class="modal timeout-modal">
    <div class="modal-content">
      <p>Your session will expire in <span id="countdown"></span></p>
      <p>Please click below if you would like to continue.</p>
      <button class="btn btn-primary modal-btn" id="renew" type="button">Renew Session</button>
    </div>
  </div>`
)

let renewModal = $("#renew-modal")

// When the renew button is clicked renew session and fetch new timeout then close modal
$("body").on("click", "#renew", function(e) {
  e.preventDefault()

  $.ajax({
    url: "/api/session/renew", 
    type: "post",
    processData: false,
    contentType: false,
    success: function(res) {
      $("#session_timeout").data("session_expiration", res.new_timeout)
      renewModal.modal("hide")
    },
    error: function(err) {
      console.log("Something went wrong")
    }
  })
})

// Countdown interval and session timeout checking
let countdown = null
setInterval(() => {
  const session_expiration = $("#session_timeout").data("session_expiration")
  const now = Math.floor(new Date().getTime()/1000)

  // When current time gets within 2 minutes of session timeout show countdown modal
  if (now === (session_expiration - 120)) {
    let seconds = 60
    let minutes = 1

    countdown = setInterval(function() {
      seconds--;
      seconds = seconds < 10 ? "0" + seconds : seconds;

      if (minutes == 1 && seconds == 0) {
        seconds = 60
        minutes = 0
        time = seconds
      }
      if (minutes == 0 && seconds == 0) {
        clearInterval(countdown);
      }

      let time = `${minutes}:${seconds}`

      document.getElementById("countdown").textContent = time;

      if (seconds <= 0) clearInterval(countdown);
    }, 1000);

    renewModal.modal("show")
  }

  // If session expiration gets renewed then clear the countdown interval
  if (now < session_expiration - 120) { 
    clearInterval(countdown) 
  }

  // If the current time gets to the session expiration time then show logged out modal
  if (now === (session_expiration)) {
    $.ajax({
      url: "/api/session/logout",
      type: "post",
      processData: false,
      contentType: false,
      success: function(res) {
        location.replace("/sign-in/new?inactive=true")
      },
      error: function(err) {
        console.log("Something went wrong")
      }
    })
  }

}, 1000);

$("#local-timezone-input").val( Intl.DateTimeFormat().resolvedOptions().timeZone)
