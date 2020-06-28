$("input[type=text]#challenge_title").on("input", function() {
  set_custom_url_example()
})

$("input[type=text]#challenge_custom_url").on("input", function() {
  set_custom_url_example()
})

function title_to_url_slug(title) {
  return title.trim().toLowerCase().replace(/ /g, "-") 
}

function set_custom_url_example() {
  challenge_title_input_value = $("input[type=text]#challenge_title").val()
  custom_url_input_value = $("input[type=text]#challenge_custom_url").val()
  custom_url_example_text = $("#custom-url-example")

  if (custom_url_example_text.length > 0) {
    if (custom_url_input_value != "") {
      challenge_title_slug = title_to_url_slug(custom_url_input_value)
      custom_url_example_text.html(challenge_title_slug)
    } else {
      challenge_title_slug = title_to_url_slug(challenge_title_input_value)
      custom_url_example_text.html(challenge_title_slug)
    }
  }
}

set_custom_url_example()