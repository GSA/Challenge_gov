csrf_token = $("input[name='_csrf_token']").val()

$.ajaxPrefilter(function (options, originalOptions, jqXHR) {
  jqXHR.setRequestHeader('X-CSRF-Token', csrf_token);
});

// Q: what's ".dap_report_file"
// A: choose file button

// Q: what's ".dap_file_upload"
// A: upload button

$(".dap-file-upload").on("change", ".dap_report_file", function() {
  $(this).removeClass("is-invalid")
})

// function(e)?

$(".dap-file-upload").on("click", ".dap_report_upload", function() {
  parentComponent = $(this).parents(".dap-file-upload")

  nameInput = $(this).siblings(".dap_file_name")
  name = nameInput.val()

  fileInput = $(this).siblings(".dap_report_file")
  // ?
  file = fileInput.prop("files")[0]

  fd = new FormData()
  fd.append("document[file]", file)
  fd.append("document[name]", name)

  if (file) {
    $.ajax({
      url: "/api/dap_reports",
      type: "post",
      processData: false,
      contentType: false,
      data: fd,
      success: function(document) {
        $(nameInput).val("")
        $(fileInput).val("")

        challengeDocuments.append(`
          <div>
            <i class="fa fa-paperclip mr-1"></i>
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

$(".dap_uploaded_report").on("click", ".dap_uploaded_report_delete", function(e) {
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
