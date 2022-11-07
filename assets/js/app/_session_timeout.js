//  $(".wrapper").prepend(
//    `<button type="button" id="showModal" class="btn btn-primary d-none" tabindex="-1" data-bs-toggle="modal" data-bs-target="#renew-modal">
//     </button>
//    <div class="modal fade timeout-modal" id="renew-modal" data-bs-backdrop="static" tabindex="-1" aria-labelledby="exampleModalLabel" aria-hidden="true">
//    <div class="modal-dialog">
//      <div class="modal-content">
//        <div class="modal-header">
//          <h1 class="modal-title fs-5" id="exampleModalLabel">Session timeout</h1>
//          <button type="button" class="btn-close" id="close-modal-session" data-bs-dismiss="modal" aria-label="Close"></button>
//        </div>
//        <div class="modal-body">
//             <p>Your session will expire in <span id="countdown"></span></p>
//             <p>Please click below if you would like to continue.</p>
//             <button class="btn btn-primary modal-btn" id="renew" type="button">Renew Session</button>
//        </div>
//      </div>
//    </div>
//  </div>
//  `)

if ($("#session_timeout").length > 0) {
  let doRenewSession = false

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
    renewSession()
  })

  $("html").on("click", () => {
    doRenewSession = true
  })

  $("html").on("keydown", () => {
    doRenewSession = true
  })

  const renewSession = () => {
    $.ajax({
      url: "/api/session/renew", 
      type: "post",
      processData: false,
      contentType: false,
      success: function(res) {
        $("#session_timeout").data("session_expiration", res.new_timeout)
        //renewModal.modal("hide")
        renewModal.hide()
        doRenewSession = false
      },
      error: function(err) {
        console.log("Something went wrong")
      }
    })
  }

  // Countdown interval and session timeout checking
  let countdown = null
  setInterval(() => {
    const session_expiration = $("#session_timeout").data("session_expiration")
    const now = Math.floor(new Date().getTime()/1000)

    // When current time gets within 2 minutes of session timeout show countdown modal
    if (now === (session_expiration - 120)) {
      if (doRenewSession) {
        return renewSession()
      }

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

      //renewModal.modal("show")
      renewModal.show()
    }

    // If session expiration gets renewed then clear the countdown interval
    if (now < session_expiration - 120) { 
      clearInterval(countdown) 
    }

    // If the current time gets to the session expiration time then show logged out modal
    if (now === (session_expiration)) {
      if (doRenewSession) {
        return renewSession()
      }

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

  setInterval(() => {
    if (doRenewSession) {
      renewSession()
    }
  }, 30000)
}