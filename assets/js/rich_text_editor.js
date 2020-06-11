import Quill from "quill"
import { QuillDeltaToHtmlConverter } from "quill-delta-to-html"

// Rich text generator
$(".rt-textarea").each(function(textarea) {
  let element = this
  let quill = new Quill(element, {
    theme: 'snow',
    placeholder: "Enter text..."
  });

  let fieldName = $(this).data("input")
  let richTextInput = $(`#${fieldName}`)
  let deltaInput = $(`#${fieldName}_delta`)
  let initialDelta = JSON.parse(deltaInput.val() || "{}")

  quill.setContents(initialDelta)

  quill.on("text-change", function(delta, oldDelta, source) {
    let cfg = {}
    let converter = new QuillDeltaToHtmlConverter(quill.getContents().ops, cfg)
    let length = quill.getText().trim().length

    if (length === 0) {
      clearInputs()
    } else {
      deltaInput.val(JSON.stringify(quill.getContents()))
      richTextInput.val(converter.convert())
    }
  })

  function clearInputs() {
    deltaInput.val("")
    richTextInput.val("")
  }
})
