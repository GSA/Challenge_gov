let phaseDeletionWarning = "Removing a phase will delete all content for this phase in other sections of the form (i.e. Judging, Resources, How to Enter). Are you sure you want to remove this phase?"

// Generic dynamic nested fields
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

// Challenge phases dynamic nested fields
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

  template.find(".form-collection").find(".nested-form-group").each(function() {
    field = $(this).data("field")
    label = $(this).find(".template-label")
    inputs = $(this).find(".template-input")
    nonCheckboxInputs = $(this).find(".template-input:not(input[type=checkbox])") 

    newId = `${parentClass}_${childClass}_${nextIndex}_${field}`
    newName = `${parentClass}[${childClass}][${nextIndex}][${field}]`

    label.attr("for", newId)
    if (field == "title") { label.text(`Phase ${nextIndex + 1} title *`) }
    if (field == "start_date") { label.text(`Phase ${nextIndex + 1} submission start date and time *`) }
    if (field == "end_date") { label.text(`Phase ${nextIndex + 1} submission end date and time *`) }

    inputs.attr("id", newId)
          .attr("name", newName)

    nonCheckboxInputs.prop("required", true)
  })

  template.find(".remove-nested-section").text(`Remove phase ${nextIndex + 1}`)

  nestedSection.append(form_collection)
})

$(".phase-fields").on("click", ".remove-nested-section", (e) => {
  e.preventDefault()
  if (window.confirm(phaseDeletionWarning)) {
    parent = $(e.target).closest(".form-collection")
    parent.hide()
    parent.find(".delete-phase").val(true)
  }
})

// Challenge timeline events dynamic nested fields  
$(".timeline-event-fields").on("click", ".add-nested-section", (e) => {
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

  template.find(".form-collection").find(".nested-form-group").each(function() {
    field = $(this).data("field")
    label = $(this).find(".template-label")
    inputs = $(this).find(".template-input")

    newId = `${parentClass}_${childClass}_${nextIndex}_${field}`
    newName = `${parentClass}[${childClass}][${nextIndex}][${field}]`

    label.attr("for", newId)

    if (Object.keys(inputs).length > 3) {
      $(Object.values(inputs)[0]).attr("id", `${newId}_picker`)
      $(Object.values(inputs)[1]).attr("id", newId)
    } else {
      inputs.attr("id", newId)
    }

    inputs.attr("name", newName)
          .prop("required", true)
  })

  nestedSection.append(form_collection)
})

$(".timeline-event-fields").on("click", ".remove-nested-section", (e) => {
  e.preventDefault()
  if (window.confirm("Are you sure you want to remove this event?")) {
    parent = $(e.target).closest(".form-collection")
    parent.remove()
  }
})

// Challenge timeline events dynamic nested fields  
$("#js-federal-partners").on("click", ".add-nested-section", (e) => {
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

  template.find(".form-collection").find(".nested-form-group").each(function() {
    field = $(this).data("field")
    label = $(this).find(".template-label")
    inputs = $(this).find(".template-input")

    newId = `${parentClass}_${childClass}_${nextIndex}_${field}`
    newName = `${parentClass}[${childClass}][${nextIndex}][${field}]`

    label.attr("for", newId)

    inputs.attr("id", newId)
          .attr("name", newName)

    if (field === "agency_id") {
      inputs.prop("required", true)
    }
  })

  nestedSection.append(form_collection)
})

$("#js-federal-partners").on("click", ".remove-nested-section", (e) => {
  e.preventDefault()
  if (window.confirm("Are you sure you want to remove this federal partner?")) {
    parent = $(e.target).closest(".form-collection")
    parent.remove()
  }
})

// Individual winners dynamic nested fields
$("#winners-form").on("click", ".js-dynamic-nested-add", (e) => {
  template = $(e.target).siblings(".js-dynamic-nested-template").clone()
  nestedItems = $(e.target).siblings(".js-dynamic-nested-items")

  lastIndex = nestedItems.find(".js-dynamic-nested-item").last().data("index")
  nextIndex = lastIndex + 1 || 0

  nestedItem = template.find(".js-dynamic-nested-item")

  parentClass = $(e.target).data("parent")
  childClass = $(e.target).data("child")

  nestedItem.attr("data-index", nextIndex)

  nestedItem.find(".js-dynamic-nested-group").each(function() {
    label = $(this).find("label")
    input = $(this).find("input")
    field = input.data("field")

    newId = `${parentClass}_${childClass}_${nextIndex}_${field}`
    newName = `${parentClass}[${childClass}][${nextIndex}][${field}]`

    label.attr("for", newId)

    input.attr("id", newId)
          .attr("name", newName)
  })

  nestedItems.append(nestedItem)
})

$("#winners-form").on("click", ".js-dynamic-nested-remove", (e) => {
  e.preventDefault()

  if (window.confirm("Are you sure you want to remove this winner?")) {
    parent = $(e.target).closest(".js-dynamic-nested-item")

    index = parent.data("index")
    removeInput = $(`#phase_winner_winners_${index}_remove`)

    $(removeInput).val(true)
    parent.addClass("d-none")
  }
})