import Quill from "quill"
import { QuillDeltaToHtmlConverter } from "quill-delta-to-html"
import { stripHtml } from "string-strip-html";

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
  [{ 'header': '1' }, { 'header': '2' }],
  [{ 'list': 'ordered' }, { 'list': 'bullet'}, { 'indent': '-1' }, { 'indent': '+1' }],
  [ 'link' ], // ['image', 'video', 'formula' ],
  [ 'clean' ]
]

$(".rt-textarea").each(function(textarea) {
  var SizeStyle = Quill.import('attributors/style/size');
  // var IndentStyle = Quill.import('attributors/style/indent');
  Quill.register(SizeStyle, true);
  // Quill.register(IndentStyle, true);

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

  // make sure the tooltip has no remaining errors in new instance
  quill.theme.tooltip.show = function() {
    $(this.root).removeClass('is-invalid');
    $("span").remove('.text-danger')
    $("span").remove('.text-secondary')
    tooltipShow.call(this);
  }

  // show errors on save when missing https
  quill.theme.tooltip.save = function() {
    var url = this.textbox.value;
    // clean out any previous errors
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

  const richTextDeltaValue = richTextInput.val()
  const deltaInputValue = deltaInput.val()

  // if text value but no delta, convert text and set contents
  // (eg editor set on field after field value already existed as a string only)
  if (richTextDeltaValue && !deltaInputValue) {
    const delta = quill.clipboard.convert(richTextDeltaValue)
    quill.setContents(delta, 'silent')
  } else {
    quill.setContents(initialDelta)
  }

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

  const setCharLimitHelperText = (charsRemaining, displayNumber, displayText) => {
    if (Math.sign(charsRemaining) != -1) {
      displayNumber.css("color", "inherit")
      displayText.css("color", "inherit")
      displayNumber.text(charsRemaining)
      displayText.text(" characters remaining")
    } else {
      displayNumber.css("color", "#dc3545")
      displayText.css("color", "#dc3545")
      displayNumber.text(`${charsRemaining * -1}`)
      displayText.text(" characters over the limit")
    }
  }

  if ($(this).hasClass("rt_char-limited")) {
    const charLimit = $(this).data("limit")
    const lengthInput = $(`#${fieldName}_length`)
    const charsRemaining = $(`#${fieldName}_chars-remaining`)
    const charLimitText = $(`#${fieldName}_char-limit-text`)
    let initialCharsRemaining = charLimit - (quill.getLength() - 1)

    // set inital values
    lengthInput.val(quill.getLength() - 1)
    if ((quill.getLength() - 1) === 0) {
      charsRemaining.css("color", "inherit")
      charLimitText.css("color", "inherit")
      charsRemaining.text(charLimit)
      charLimitText.text(" characters remaining")
    } else {
      setCharLimitHelperText(initialCharsRemaining, charsRemaining, charLimitText)
    }

    quill.on('text-change', function() {
      let numCharsRemaining = charLimit - (quill.getLength() - 1)
      lengthInput.val(quill.getLength() - 1)
      setCharLimitHelperText(numCharsRemaining, charsRemaining, charLimitText)
    });
  }
})
