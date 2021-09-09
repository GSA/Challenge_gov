csrf_token = $("input[name='_csrf_token']").val()

$.ajaxPrefilter(function (options, originalOptions, jqXHR) {
  jqXHR.setRequestHeader('X-CSRF-Token', csrf_token);
});

$(".winners-overview").on("change", "#phase_winner_overview_image", (e) => {
  $(e.target).removeClass("is-invalid")
})

$(".winners-overview").on("change", "#phase_winner_overview_image", (e) => {
  form = e.target.form
  phaseWinnerId = $(form).data("phase-winner-id")
  formGroup = e.target.closest(".form-group")

  fileInput = $(e.target)
  file = fileInput.prop("files")[0]

  fd = new FormData()
  fd.append("overview_image", file)

  if (file) {
    $.ajax({
      url: `/api/phase_winners/${phaseWinnerId}/upload_overview_image`,
      type: "post",
      processData: false,
      contentType: false,
      data: fd,
      success: function({key, extension}) {
        $("#phase_winner_overview_image_key").val(key)
        $("#phase_winner_overview_image_extension").val(extension)
      },
      error: function(err) {
        console.log("Something went wrong", err)
        $(fileInput).addClass("is-invalid")
      }
    })
  }
})
