$(".js-clickable-table-row").on("click", function() {
  link = $(this).data("link")
  window.location = link
})