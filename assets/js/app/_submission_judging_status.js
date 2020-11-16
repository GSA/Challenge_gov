$(() => {
  csrf_token = document.querySelector('meta[name="csrf-token"]').content

  $.ajaxPrefilter(function (options, originalOptions, jqXHR) {
    jqXHR.setRequestHeader('X-CSRF-Token', csrf_token);
  });

  $(".js-select-for-judging").on("click", (e) => {
    e.preventDefault()

    $.ajax({
      method: "PUT",
      url: e.target.href
    }).done((res) => {
      $(e.target).text(res.text)
      $(e.target).attr("href", res.route)
      $(e.target).attr("class", res.class)
    }).fail((err) => {
      console.log("failure", err)
    })
  })
});
