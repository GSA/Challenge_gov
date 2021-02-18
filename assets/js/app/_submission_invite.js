const submitButton = $("#submission-invites__submit")
const selectAllCheckbox = $("#submission-invites__select-all")
const individualCheckboxes = $(".submission-invites__checkbox")

selectAllCheckbox.on("change", (e) => {
  individualCheckboxes.prop("checked", e.target.checked)
  checkSubmitRequirements()
})

individualCheckboxes.on("change", (e) => {
  checkSelectAllStatus()
  checkSubmitRequirements()
})

// Grabs the quill element that is set in rich_text_editor.js to attach event listener
// Track message length to enable/disable submit button
quill = $(".submission-invites__message .rt-textarea").data("quill")
if (quill) {
  quill.on('text-change', function(delta, source) {
    checkSubmitRequirements()
  });
}

const checkSelectAllStatus = () => {
  const individualCheckboxCount = individualCheckboxes.length
  const selectedSubmissionCount = $(".submission-invites__checkbox:checked").length

  selectAllCheckbox.prop("checked", selectedSubmissionCount === individualCheckboxCount)
}

const checkSubmitRequirements = () => {
  const selectedSubmissionCount = $(".submission-invites__checkbox:checked").length
  const messageLength = quill.getLength()

  submitButton.prop("disabled", selectedSubmissionCount === 0 || messageLength === 1)
}