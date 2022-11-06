csrf_token = $("input[name='_csrf_token']").val()

$.ajaxPrefilter(function (options, originalOptions, jqXHR) {
  jqXHR.setRequestHeader('X-CSRF-Token', csrf_token);
});

$(".challenge-file-upload").on("change", ".challenge_document_file", function() {
  $(this).removeClass("is-invalid")
})

$(".challenge-file-upload").on("click", ".challenge_document_upload", function() {
  parentComponent = $(this).parents(".challenge-file-upload")

  challengeId = $("#challenge_challenge_id").val()
  section = parentComponent.data("section")

  nameInput = $(this).siblings(".challenge_document_name")
  name = nameInput.val()
  fileInput = $(this).siblings(".challenge_document_file")
  file = fileInput.prop("files")[0]
  challengeDocuments = parentComponent.find(".challenge_uploaded_documents")


  fd = new FormData()
  fd.append("challenge_id", challengeId)
  fd.append("document[file]", file)
  fd.append("document[section]", section)
  fd.append("document[name]", name)

  if (file) {
    $.ajax({
      url: "/api/documents", 
      type: "post",
      processData: false,
      contentType: false,
      data: fd,
      success: function(document) {
        $(nameInput).val("")
        $(fileInput).val("")

        challengeDocuments.append(`
          <div>
            <i class="fa fa-paperclip me-1"></i>
            <a href=${document.url} target="_blank">${document.display_name}</a>
            <a href="" data-document-id=${document.id} class="challenge_uploaded_document_delete">
              <i class="fa fa-trash"></i>
            </a>
          </div>
        `)
      },
      error: function(err) {
        console.log("Something went wrong")
        $(fileInput).addClass("is-invalid")
      }
    })
  }
})

$(".challenge_uploaded_documents").on("click", ".challenge_uploaded_document_delete", function(e) {
  e.preventDefault()

  document_id = $(this).data("document-id")
  parent_element = $(this).parent()

  $.ajax({
    url: `/api/documents/${document_id}`, 
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