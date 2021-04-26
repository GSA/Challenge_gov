csrf_token = $("input[name='_csrf_token']").val()

$.ajaxPrefilter(function (options, originalOptions, jqXHR) {
  jqXHR.setRequestHeader('X-CSRF-Token', csrf_token);
});

$(".winners-overview").on("change", "#phase_winner_overview_image", (e) => {
  form = e.target.form
  phaseWinnerId = $(form).data("phase-winner-id")
  formGroup = e.target.closest(".form-group")

  file = $(e.target).prop("files")[0]

  fd = new FormData()
  fd.append("overview_image", file)

  if (file) {
    $.ajax({
      url: `/api/phase_winners/${phaseWinnerId}/upload_overview_image`, 
      type: "post",
      processData: false,
      contentType: false,
      data: fd,
      success: function({overview_image_path}) {
        $("#phase_winner_overview_image_path").val(overview_image_path)
      },
      error: function(err) {
        console.log("Something went wrong", err)
      }
    })
  }
})

$(".winners-overview").on("change", "[data-field=image]", (e) => {
  form = e.target.form
  phaseWinnerId = $(form).data("phase-winner-id")
  formGroup = e.target.closest(".form-group")
  rowElement = e.target.closest(".grid-row")
  imagePathElement = $(rowElement).find("[data-field=image_path]")

  file = $(e.target).prop("files")[0]

  fd = new FormData()
  fd.append("image", file)

  if (file) {
    $.ajax({
      url: `/api/phase_winners/${phaseWinnerId}/upload_winner_image`, 
      type: "post",
      processData: false,
      contentType: false,
      data: fd,
      success: function({image_path}) {
        $(imagePathElement).val(image_path)
      },
      error: function(err) {
        console.log("Something went wrong", err)
      }
    })
  }
})