$(document).ready(function(){
	$(".js-select").select2({
    width: "100%"
  })
	$(".js-multiselect").select2({
    width: "100%"
  })

  $(".dynamic-nested-form").on("click", ".add-nested-section", (e) => {
    e.preventDefault()

    template = $(e.target).siblings(".dynamic-nested-form-template").clone()

    nestedSection = $(e.target).siblings(".nested-items")
    nestedItems = $(e.target).siblings(".nested-items").children(".form-collection")

    lastIndex = nestedItems.last().data("index")
    nextIndex = lastIndex + 1 || 0

    parentClass = $(e.target).data("parent")
    childClass = $(e.target).data("child")

    form_collection = template.find(".form-collection")
    form_collection.attr("data-index", nextIndex)

    template.find(".form-collection").children(".nested-form-group").each(function() {
      field = $(this).data("field")

      $(this).find(".template-label")
        .attr("for", `${parentClass}_${childClass}_${nextIndex}_${field}`)

      $(this).find(".template-input")
        .attr("id", `${parentClass}_${childClass}_${nextIndex}_${field}`)
        .attr("name", `${parentClass}[${childClass}][${nextIndex}][${field}]`)
    })

    nestedSection.append(form_collection)
  })
  
  $(".dynamic-nested-form").on("click", ".btn.remove-nested-section", (e) => {
    e.preventDefault()
    parent = $(e.target).closest(".form-collection")
    parent.remove()
  })

  $(".phase-fields").on("click", ".add-nested-section", (e) => {
    e.preventDefault()

    template = $(e.target).siblings(".dynamic-nested-form-template").clone()

    nestedSection = $(e.target).siblings(".nested-items")
    nestedItems = $(e.target).siblings(".nested-items").children(".form-collection")

    lastIndex = nestedItems.last().data("index")
    nextIndex = lastIndex + 1 || 0

    parentClass = $(e.target).data("parent")
    childClass = $(e.target).data("child")

    form_collection = template.find(".form-collection")
    form_collection.attr("data-index", nextIndex)

    template.find(".form-collection").children(".nested-form-group").each(function() {
      field = $(this).data("field")

      $(this).find(".template-label")
        .attr("for", `${parentClass}_${childClass}_${nextIndex}_${field}`)

      $(this).find(".template-input")
        .attr("id", `${parentClass}_${childClass}_${nextIndex}_${field}`)
        .attr("name", `${parentClass}[${childClass}][${nextIndex}][${field}]`)

      $(this).find(".template-input:not(input[type=checkbox])") 
        .prop("required", true)
    })

    nestedSection.append(form_collection)
  })

  $(".phase-fields").on("click", ".remove-nested-section", (e) => {
    e.preventDefault()
    parent = $(e.target).closest(".form-collection")
    parent.remove()
  })
})