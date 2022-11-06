csrf_token = $("input[name='_csrf_token']").val()

$.ajaxPrefilter(function (options, originalOptions, jqXHR) {
  jqXHR.setRequestHeader('X-CSRF-Token', csrf_token);
});

$("#submission_document").on("change", function() {
  $(this).removeClass("is-invalid")
})

$("#submission_document_upload").on("click", function(e) {
  name_input = $("#submission_document_name")
  name = name_input.val()
  current_user = $("#current_user").data("user")
  solver_email_input = $("#submission_solver_addr")
  solver_email = solver_email_input.val() || current_user
  file_input = $("#submission_document")
  file = file_input.prop("files")[0]

  fd = new FormData()
  fd.append("document[file]", file)
  fd.append("document[name]", name)
  fd.set("solver_email", solver_email)

  if (file) {
    $.ajax({
      url: "/api/submission_documents",
      type: "post",
      processData: false,
      contentType: false,
      data: fd,
      success: function(document) {
        $("#submission_document_upload__error-no-email").text("")
        $("#submission_document_upload__error-solver-addr").text("").css("padding-bottom", "0")

        $(name_input).val("")
        $(file_input).val("")

        $(".submission-documents-list").append(`
          <div class="submission-document-row">
            <input type="hidden" name="submission[document_ids][]" value="${document.id}">
            <i class="fa fa-paperclip me-1"></i>
            <a href=${document.url} target="_blank">${document.display_name}</a>
            <a href="" data-document-id=${document.id} class="submission_uploaded_document_delete">
              <i class="fa fa-trash"></i>
            </a>
          </div>
        `)
      },
      error: function(err) {
        console.log("Something went wrong")
        if(err["solver_addr"]) {
          handleFileUploadError(err.responseJSON.errors)
        } else {
          $(file_input).addClass("is-invalid")
        }
      }
    })
  }
})

const handleFileUploadError = (errors) => {
  const noEmailErrorTag = $("#submission_document_upload__error-no-email")
  const emailNotFoundErrorTag = $("#submission_document_upload__error-solver-addr")
  
  if (errors["solver_addr"][0] === "must add solver email first") {
    // reset other js error
    emailNotFoundErrorTag.text("").css("padding-bottom", "0")
    noEmailErrorTag.text(`${errors["solver_addr"]}`)
  } else if (errors["solver_addr"][0] === "user not found") {
    // reset other js error
    noEmailErrorTag.text("")
    emailNotFoundErrorTag.text(`${errors["solver_addr"]}`).css("padding-bottom", "16px")
  }
}

$(".submission-documents-list").on("click", ".submission_uploaded_document_delete", function(e) {
  e.preventDefault()

  document_id = $(this).data("document-id")
  parent_element = $(this).parents(".submission-document-row")

  $.ajax({
    url: `/api/submission_documents/${document_id}`, 
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
