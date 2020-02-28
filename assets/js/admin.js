// Import External libraries and css
import jquery from  "jquery";
import "popper.js";
import "../vendor/admin/bootstrap.min.css";
import "../vendor/admin/bootstrap.min.js";
import "admin-lte/dist/css/AdminLTE.css";
import "admin-lte/dist/css/skins/skin-blue.css";
import "admin-lte/dist/js/adminlte.js";
import "font-awesome/css/font-awesome.css";
import "phoenix_html"
import "../css/admin.css";
import "../css/progress_bar.scss";
import "./dynamic_nested_fields.js";
import "select2";

window.$ = jquery;

setInterval(() => {
  const session_expiration = $("#session_timeout").data("session_expiration")
  const now = Math.floor(new Date().getTime()/1000)
  if (now === (session_expiration - 120)) {
    let seconds = 60
    let minutes = 1
    let countdown = setInterval(function() {
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
    $(".navbar").prepend(
      `<div id="renew-modal" class="timeout-modal">
        <div class="modal-content">
          <p>Your session will expire in <span id="countdown"></span></p>
          <p>Please click below if you would like to continue.</p>
          <button class="btn btn-primary modal-btn" id="renew" type="button">Renew Session</button>
        </div>
      </div>`
    );
    $("#renew").click(() => {location.reload()})
  }
  if (now === (session_expiration)) {
    $('#renew-modal').css('display', 'none');
    $(".navbar").prepend(
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
  $("#login-modal-btn").click(() => {location.replace("sign-in/new");})
}, 1000);
