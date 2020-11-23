$(() => {
  csrf_token = document.querySelector('meta[name="csrf-token"]').content

  $.ajaxPrefilter(function (options, originalOptions, jqXHR) {
    jqXHR.setRequestHeader('X-CSRF-Token', csrf_token);
  });

  $(".js-select-for-judging").on("click", (e) => {
    e.preventDefault()
    const buttonDisabled = $(e.target).attr("disabled")

    if (!buttonDisabled) {
      $.ajax({
        method: "PUT",
        url: e.target.href
      }).done((res) => {
        updateButtonValues(e.target, res)
        updateCounts(res)
      }).fail((err) => {
        console.log("failure", err)
      })
    }
  })

  const updateButtonValues = (button, res) => {
      $(button).text(res.text)
      $(button).attr("href", res.route)
      $(button).attr("class", res.class)
  }

  const updateCounts = (res) => {
    const {status, prev_status} = res

    if (status == "selected" && prev_status == "not_selected") {
      updateSelectedCount(1)
    }
    if (status == "not_selected" && prev_status == "selected") {
      updateSelectedCount(-1)
    }
    if (status == "selected" && prev_status == "winner") {
      updateWinnerCount(-1)
    }
    if (status == "not_selected" && prev_status == "winner") {
      updateSelectedCount(-1)
      updateWinnerCount(-1)
    }
    if (status == "winner") {
      updateWinnerCount(1)
    }

    return
  }

  const updateSelectedCount = (val) => {
    selectedCountElement = $(".submission-filter__tab--selected .submission-filter__count")
    selectedCount = parseInt(selectedCountElement.html())

    selectedCountElement.html(selectedCount + val)
  }

  const updateWinnerCount = (val) => {
    winnerCountElement = $(".submission-filter__tab--winner .submission-filter__count")
    winnerCount = parseInt(winnerCountElement.html())

    winnerCountElement.html(winnerCount + val)
  }
});
