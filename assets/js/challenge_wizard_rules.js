$(document).ready(function(){
  const checkbox = $("#challenge_terms_equal_rules")
  const termsInput = $("#challenge_terms_and_conditions")

  let oldTerms = termsInput.val()

  if (checkbox.prop("checked") === true) {
    boxChecked()
  }

  if (checkbox.prop("checked") === false) {
    boxUnchecked()
  }

  checkbox.on("click", function() {
    if ($(this).prop("checked")) {
      boxChecked()
    } else {
      boxUnchecked()
    }
  })

  function boxChecked() {
    oldTerms = termsInput.val()
    termsInput.val("")
    termsInput.prop("disabled", true)
  }

  function boxUnchecked() {
    termsInput.val(oldTerms)
    termsInput.prop("disabled", false)
  }
})