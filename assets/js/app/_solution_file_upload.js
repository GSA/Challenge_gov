csrf_token = $("input[name='_csrf_token']").val()

$.ajaxPrefilter(function (options, originalOptions, jqXHR) {
  jqXHR.setRequestHeader('X-CSRF-Token', csrf_token);
});

$("#solution_document_upload").on("click", function(e) {
  name_input = $("#solution_document_name")
  name = name_input.val()
  file_input = $("#solution_document")
  file = file_input.prop("files")[0]

  fd = new FormData()
  fd.append("document[file]", file)
  fd.append("document[name]", name)

  if (file) {
    $.ajax({
      url: "/api/solution_documents", 
      type: "post",
      processData: false,
      contentType: false,
      data: fd,
      success: function(document) {
        $(name_input).val("")
        $(file_input).val("")

        $(".solution-documents-list").append(`
          <div class="row solution-document-row">
            <div class="col">
              <a href=${document.url} target="_blank">${document.display_name}</a>
            </div>
            <div class="col">
              <a href="#", class="solution_uploaded_document_delete" data-document-id="${document.id}">Remove</a>
            </div>
          </div>
        `)
        
        $(".solution-document-ids").append(`
          <input type="hidden" name="solution[document_ids][]" value="${document.id}">
        `)
      },
      error: function(err) {
        console.log("Something went wrong")
      }
    })
  }
})

$(".solution-documents-list").on("click", ".solution_uploaded_document_delete", function(e) {
  e.preventDefault()

  document_id = $(this).data("document-id")
  parent_element = $(this).parents(".solution-document-row")

  $.ajax({
    url: `/api/solution_documents/${document_id}`, 
    type: "delete",
    processData: false,
    contentType: false,
    success: function(res) {
      parent_element.remove()
    },
    error: function(err) {
      console.log("Something went wrong")
    }
  })
})