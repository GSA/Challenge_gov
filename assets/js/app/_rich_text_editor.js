import Quill from "quill"
import { QuillDeltaToHtmlConverter } from "quill-delta-to-html"

// Rich text generator
let toolbarOptions = [
  // Additional options
  // ['bold', 'italic', 'underline', 'strike'],        // toggled buttons
  // ['blockquote', 'code-block'],
  // [{ 'header': 1 }, { 'header': 2 }],               // custom button values
  // [{ 'list': 'ordered'}, { 'list': 'bullet' }],
  // [{ 'script': 'sub'}, { 'script': 'super' }],      // superscript/subscript
  // [{ 'indent': '-1'}, { 'indent': '+1' }],          // outdent/indent
  // [{ 'direction': 'rtl' }],                         // text direction
  // [{ 'size': ['small', false, 'large', 'huge'] }],  // custom dropdown
  // [{ 'header': [1, 2, 3, 4, 5, 6, false] }],
  // [{ 'color': [] }, { 'background': [] }],          // dropdown with defaults from theme
  // [{ 'font': [] }],
  // [{ 'align': [] }],
  // ['clean']      
  // [{ 'font': [] }, { 'size': [] }],
  // [{ 'color': [] }, { 'background': [] }],
  // [{ 'script': 'super' }, { 'script': 'sub' }],
  // [ 'direction', { 'align': [] }],

  // Setup some default options
  [{ 'size': [] }],
  [ 'bold', 'italic', 'underline', 'strike' ],
  [{ 'header': '1' }, { 'header': '2' }, 'blockquote', 'code-block' ],
  [{ 'list': 'ordered' }, { 'list': 'bullet'}, { 'indent': '-1' }, { 'indent': '+1' }],
  [ 'link', 'image', 'video', 'formula' ],
  [ 'clean' ]
]

$(".rt-textarea").each(function(textarea) {
  let element = this
  let quill = new Quill(element, {
    theme: 'snow',
    placeholder: "Enter text...",
    modules: {
      toolbar: toolbarOptions
    }
  });
  $(this).data("quill", quill)

  let toolBar = quill.getModule("toolbar")
  var tooltipSave = quill.theme.tooltip.save;
  var tooltipShow = quill.theme.tooltip.show;

  quill.theme.tooltip.show = function() {
    $(this.root).removeClass('is-invalid');
    $("span").remove('.text-danger')
    $("span").remove('.text-secondary')
    tooltipShow.call(this);
  }

  quill.theme.tooltip.save = function() {
    var url = this.textbox.value;
    $(this.root).removeClass('is-invalid');
    $("span").remove('.text-danger')
    $("span").remove('.text-secondary')

    let httpRegex = /^https?:\/\//i
    if(httpRegex.test(url)) {
      $(this.root).removeClass('is-invalid');
      tooltipSave.call(this);
    }
    else {
      $(this.root).addClass('is-invalid');
      $(this.root).append('<span class="text-danger">links must contain "https"</span>')
      $(this.root).append('<span class="text-secondary">tip: copy and paste url</span>')
    }
  };

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
