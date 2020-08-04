let userNotified = false

$(".phase-fields").on("click", ".add-nested-section", function() {
  if ($("#existing-phase-data-boolean").html() === "true" && !userNotified) {
    alert("Adding new phases will require you to fill out judging criteria and how to enter information for the new phases.")
    userNotified = true
  }
})