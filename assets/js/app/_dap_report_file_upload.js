csrf_token = $("input[name='_csrf_token']").val()

$.ajaxPrefilter(function (options, originalOptions, jqXHR) {
  jqXHR.setRequestHeader('X-CSRF-Token', csrf_token);
});

$(".dap-file-upload").on("change", ".dap_report_file", function() {
  $(this).removeClass("is-invalid")
})

$(".dap-file-upload").on("click", ".dap_report_upload", function() {
  parentComponent = $(this).parents(".dap-file-upload")

  nameInput = $(this).siblings(".dap_file_name")
  name = nameInput.val()

  fileInput = $(this).siblings(".dap_report_file")
  file = fileInput.prop("files")[0]
  uploadedReport = parentComponent.find(".dap_uploaded_report")

  fd = new FormData()
  fd.append("document[file]", file)
  fd.append("document[name]", name)

  if (file) {
    $(".dap_report_loading").append(`<img src="/images/loading-buffering.gif" class="loading-feedback w-25"/>`)

    $.ajax({
      url: "/api/dap_reports",
      type: "post",
      processData: false,
      contentType: false,
      data: fd,
      success: function(document) {
        $(nameInput).val("")
        $(fileInput).val("")

        setTimeout(() => {
          $(".loading-feedback").remove()

          uploadedReport.append(`
            <div>
              <i class="fa fa-paperclip me-1"></i>
              <a href=${document.url} target="_blank">${document.filename}</a>
              <a href="" data-document-id=${document.id} class="dap_uploaded_report_delete">
                <i class="fa fa-trash"></i>
              </a>
            </div>
          `)
        }, 1000);

      },
      error: function(err) {
        console.log("Something went wrong")

        setTimeout(() => {
          $(".loading-feedback").remove()
          $(fileInput).addClass("is-invalid")
        }, 1000);
      }
    })
  }
})

$(".dap_uploaded_report").on("click", ".dap_uploaded_report_delete", function(e) {
  e.preventDefault()

  document_id = $(this).data("document-id")

  parent_element = $(this).parent()

  $.ajax({
    url: `/api/dap_reports/${document_id}`,
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
