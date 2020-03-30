// Import External libraries and css
import jquery from  "jquery";
import "popper.js";
import "bootstrap/dist/css/bootstrap.css";
import "bootstrap/dist/js/bootstrap.js";
import "select2";

// Phoenix html dependency
import "phoenix_html"

// import "../vendor/admin/bootstrap.min.css";
// import "../vendor/admin/bootstrap.min.js";

import "admin-lte/dist/css/adminlte.css";
import "admin-lte/dist/js/adminlte.js";
import "@fortawesome/fontawesome-free/css/all.css";

// Custom CSS
import "../css/admin.scss";
import "../css/progress_bar.scss";

// Custom JS
import "./dynamic_nested_fields.js";
import "./radio_button_show.js";
import "./character_limit.js";
import "./datetime_field.js";
import "./custom_url_generator.js";
import "./section_file_upload.js"        

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
    $('#renew-modal').css('display', 'none');
    $(".wrapper").prepend(
      `<div id="logged-out-modal" class="timeout-modal">
        <div class="modal-content">
          <p>You have been logged out due to inactivity</p>
          <button
          class="btn btn-primary modal-btn"
          type="button"
          id="login-modal-btn"">
            Sign In
          </button>
        </div>
      </div>`
    );
  }

  // When clicking the sign in button on logged out modal redirect to sign in path
  $("#login-modal-btn").click(() => {
    $.ajax({
      url: "/api/session/logout",
      type: "post",
      processData: false,
      contentType: false,
      success: function(res) {
        location.replace("sign-in/new");
      },
      error: function(err) {
        console.log("Something went wrong")
      }
    })
  })

}, 1000);

$("#local-timezone-input").val( Intl.DateTimeFormat().resolvedOptions().timeZone)
