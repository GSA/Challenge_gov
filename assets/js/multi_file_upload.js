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