$(document).ready(function(){
  $("#solution_document").on("change", function(e) {
    console.log("Changed")
    console.log(e.target.value)
    // file_input.prop("files")[0]
    console.log($(this).prop("files")[0])
    appendedFileInput = $(this).clone().attr("id", "test")
    console.log(appendedFileInput)
    $(".solution-documents-upload-list").append(appendedFileInput)
    $(this).value = null
  })
})

$(document).ready(function(){
  csrf_token = $("input[name='_csrf_token']").val()

  $.ajaxPrefilter(function (options, originalOptions, jqXHR) {
    jqXHR.setRequestHeader('X-CSRF-Token', csrf_token);
  });

  $("#solution_document").on("change", function(e) {
    console.log("File selected")
    file_input = $(this)
    file = file_input.prop("files")[0]
    console.log(file)

    fd = new FormData()
    fd.append("document[file]", file)

    if (file) {
      $.ajax({
        url: "/api/solution_documents", 
        type: "post",
        processData: false,
        contentType: false,
        data: fd,
        success: function(document) {
          $(file_input).val("")

          $(".solution-documents-list").append(`
            <li class="row solution-document-row">
              <div class="col">
                <a href=${document.url} target="_blank">${document.filename}</a>
              </div>
              <div class="col">
                <a href="#", class="solution_uploaded_document_delete" data-document-id="${document.id}">Remove</a>
              </div>
            </li>
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
    console.log(parent_element)

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
})