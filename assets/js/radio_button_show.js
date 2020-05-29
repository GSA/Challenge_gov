$(document).ready(function(){
  let phaseDeletionWarning = "Removing a phase will delete all content for this phase in other sections of the form (i.e. Judging, Resources, How to Enter). Are you sure you want to remove this phase?"

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
  
  // Adding phases show/hide section
  if ($(".multi-phase-toggle input[type=radio][value=true]:checked").length > 0) {
    $(".phase-fields .nested-items").find("input").prop("disabled", false)
    $(".phase-fields").collapse("show")
    $(".single-phase-section").collapse("hide")
  }

  if ($(".multi-phase-toggle input[type=radio][value=false]:checked").length > 0) {
    $(".phase-fields .nested-items").find("input").prop("disabled", true)
    $(".phase-fields").collapse("hide")
    $(".single-phase-section").collapse("show")
  }

  $(".multi-phase-toggle input[type=radio]").on("click", function() {
    if ($(this).val() == "true") {
      $(".phase-fields").collapse("show")
      $(".single-phase-section").collapse("hide")
      $(".phase-fields .nested-items").find("input").prop("disabled", false)
    } else {
      if (window.confirm(phaseDeletionWarning)) {
        $(".phase-fields").collapse("hide")
        $(".single-phase-section").collapse("show")
        $(".phase-fields .nested-items").find("input").prop("disabled", true)
        return true
      } else {
        return false
      }
    }
  })
})