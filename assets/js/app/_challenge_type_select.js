let challengeTypeSelects = $("select.js-challenge-type")

challengeTypeSelects.on("change", (e) => {
  disableSelectedTypes()
})

disableSelectedTypes()

function disableSelectedTypes() {
  let selectedValues = challengeTypeSelects.map((i, e) => {
    return e.value
  })
  
  challengeTypeSelects.each((i, e) => {
    $(e).children().each((i, o) => {
      $(o).prop("disabled", false)

      if ($.inArray(o.value, selectedValues) >= 0 && e.value !== o.value && o.value !== "") {
        $(o).prop("disabled", true)
      }
    })
  })
}