import Quill from "quill"
import { QuillDeltaToHtmlConverter } from "quill-delta-to-html"

// Rich text generator
$(".rt-textarea").each(function(textarea) {
  let element = this
  let quill = new Quill(element, {
    theme: 'snow'
  });

  let fieldName = $(this).data("input")
  console.log(fieldName)
  let richTextInput = $(`#${fieldName}`)
  let deltaInput = $(`#${fieldName}_delta`)
  let initialDelta = JSON.parse(deltaInput.val() || "{}")

  console.log(initialDelta)

  quill.setContents(initialDelta)

  quill.on("text-change", function(delta, oldDelta, source) {
    let cfg = {}
    let converter = new QuillDeltaToHtmlConverter(quill.getContents().ops, cfg)

    console.log(quill.getContents())
    console.log(converter.convert())
    console.log(deltaInput)
    console.log(richTextInput)

    deltaInput.val(JSON.stringify(quill.getContents()))
    richTextInput.val(converter.convert())
  })
})