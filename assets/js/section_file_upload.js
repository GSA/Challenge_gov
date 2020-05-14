$(document).ready(function(){
  csrf_token = $("input[name='_csrf_token']").val()

  $.ajaxPrefilter(function (options, originalOptions, jqXHR) {
    jqXHR.setRequestHeader('X-CSRF-Token', csrf_token);
  });

  $("#challenge_document_upload").on("click", function() {
    section = $("#challenge_section").val()
    challenge_id = $("#challenge_challenge_id").val()
    name_input = $("#challenge_document_name")
    name = name_input.val()
    file_input = $("#challenge_document_file")
    file = file_input.prop("files")[0]

    fd = new FormData()
    fd.append("challenge_id", challenge_id)
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
          $(name_input).val("")
          $(file_input).val("")

          $("#challenge_uploaded_documents").append(`
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
        }
      })
    }
  })

  $("#challenge_uploaded_documents").on("click", ".challenge_uploaded_document_delete", function(e) {
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
})