$(".js-clickable-table-row").on("click", function() {
  redirectToTableRowLink(this)
})

$(".js-clickable-table-row").on("keydown", function(e) {
  if (e.keyCode == 13 || e.keyCode == 32) {
    redirectToTableRowLink(this)
  }
})

const redirectToTableRowLink = (row) => {
  link = $(row).data("link")
  window.location = link
}

$(".js-table-row-select").on("click", (e) => {
  e.stopPropagation()
})