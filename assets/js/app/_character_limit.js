$(".char-limit-input").each(function() {
  checkCharacterLimit($(this))
})

$(".char-limit-input").on("input", function() {
  checkCharacterLimit($(this))
})

function checkCharacterLimit(input) {
  curr_length = input.val().length
  char_limit = input.attr("limit")
  chars_remaining = char_limit - curr_length
  char_limit_label = input.siblings(".char-limit-label")

  if (chars_remaining >= 0) {
    $(char_limit_label).html(chars_remaining + " characters remaining")
    $(char_limit_label).removeClass("is-invalid")
  } else {
    $(char_limit_label).html(Math.abs(chars_remaining) + " characters over limit")
    $(char_limit_label).addClass("is-invalid")
  }

}