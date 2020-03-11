$(document).ready(function(){
  if ($(".upload-logo input[type=radio][value=true]:checked").length > 0) {
    $(".logo-file-field").collapse("show")
  }

  $(".upload-logo input[type=radio]").on("click", function() {
    if ($(this).val() == "true") {
      $(".logo-file-field").collapse("show")
    } else {
      $(".logo-file-field").collapse("hide")
      $(".logo-file-field input").val("")
    }
  })
})