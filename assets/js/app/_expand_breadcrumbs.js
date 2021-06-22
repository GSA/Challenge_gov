$(".breadcrumb-item").on("click", ".hidden-breadcrumbs", function(e) {
  e.preventDefault()

  const parent = $(this).parent()
  const olGrandParent = $(".breadcrumb")
  const hiddenBreadcrumbs = $(".truncated-breadcrumbs").data("breadcrumbs")

  const breadcrumbHTML = hiddenBreadcrumbs.reduce((acc, breadcrumb) => {
    item = `<li class="breadcrumb-item"><a href="${breadcrumb.route}">${breadcrumb.text}</a></li>`
    return acc + item
  }, ``)

  parent.replaceWith(breadcrumbHTML)
})
