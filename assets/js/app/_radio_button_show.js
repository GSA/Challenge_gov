let phaseDeletionWarning = "Removing a phase will delete all content for this phase in other sections of the form (i.e. Judging, Resources, How to Enter). Are you sure you want to remove this phase?"

if ($(".upload-logo input[type=radio][value=true]:checked").length > 0) {
  $(".logo-file-field").toggle(true)
}

$(".upload-logo input[type=radio]").on("click", function() {
  if ($(this).val() == "true") {
    $(".logo-file-field").toggle(true)
  } else {
    $(".logo-file-field").toggle(false)
    $(".logo-file-field input").val("")
  }
})

// Adding phases show/hide section
if ($(".multi-phase-toggle input[type=radio][value=true]:checked").length > 0) {

  $(".phase-fields .nested-items").find("input").prop("disabled", false)
  $(".phase-fields").toggle(true)
  $(".single-phase-section").toggle(false)
  $(".single-phase-section").find("input").prop("disabled", true)
}

if ($(".multi-phase-toggle input[type=radio][value=false]:checked").length > 0) {

  $(".phase-fields .nested-items").find("input").prop("disabled", true)
  $(".phase-fields").toggle(false)
  $(".single-phase-section").toggle(true)
  $(".single-phase-section").find("input").prop("disabled", false)
}

$(".multi-phase-toggle input[type=radio]").on("click", function() {
  if ($(this).val() == "true") {
    $(".phase-fields").toggle(true)
    $(".phase-fields .nested-items").find("input").prop("disabled", false)
    $(".single-phase-section").toggle(false)
  $(".single-phase-section").find("input").prop("disabled", true)
  } else {
    if (!$("#challenge_phases_0_start_date").val()) {
      showSinglePhaseFields()
      return true
    } else if (!!$("#challenge_phases_0_start_date").val() && window.confirm(phaseDeletionWarning)) {
      showSinglePhaseFields()
      return true
    } else {
      return false
    }
  }
})

// Prize details show/hide input  
const prizeTotalSection = $(".js-prize-total.collapse")
const nonMonetaryPrizeSection = $(".js-non-monetary-prize.collapse")

if ($(".js-prize-detail-toggle input[type=radio][value='monetary']:checked").length > 0) {
  showMonetaryPrize()
}

if ($(".js-prize-detail-toggle input[type=radio][value='non_monetary']:checked").length > 0) {
  showNonMonetaryPrize()
}

if ($(".js-prize-detail-toggle input[type=radio][value='both']:checked").length > 0) {
  showBothPrizes()
}

$(".js-prize-detail-toggle input[type=radio]").on("click", function() {
  switch ($(this).val()) {
    case "monetary":
      return showMonetaryPrize()
    case "non_monetary":
      return showNonMonetaryPrize()
    case "both":
      return showBothPrizes()
    default:
      console.log("Could not show prize inputs")
      break;
  }
})

function showSinglePhaseFields() {
  $(".phase-fields").toggle(false)
  $(".phase-fields .nested-items").find("input").prop("disabled", true)
  $(".single-phase-section").toggle(true)
  $(".single-phase-section").find("input").prop("disabled", false)
  $(".phase-fields .id").prop("disabled", false)
  $(".delete-phase").prop("disabled", false)
  $(".delete-phase").val(true)
}

function showMonetaryPrize() {
  prizeTotalSection.toggle(true)
  prizeTotalSection.find("input").prop("disabled", false)
  nonMonetaryPrizeSection.toggle(false)
  nonMonetaryPrizeSection.find("input").prop("disabled", true)
}

function showNonMonetaryPrize() {
  nonMonetaryPrizeSection.toggle(true)
  nonMonetaryPrizeSection.find("input").prop("disabled", false)
  prizeTotalSection.toggle(false)
  // prizeTotalSection.find("input").prop("disabled", true)
}

function showBothPrizes() {
  prizeTotalSection.toggle(true)
  prizeTotalSection.find("input").prop("disabled", false)
  nonMonetaryPrizeSection.toggle(true)
  nonMonetaryPrizeSection.find("input").prop("disabled", false)
}