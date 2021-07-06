$(".message_center__challenge_filter").on("change", function() {
  this.form.submit()
})

$(".message_center__message_form").on("submit", (e) => {
  e.preventDefault()

  const messages = $(".message_center__messages")
  const quill = $(".message_center .rt-textarea").data("quill")

  if (quill) {
    if (quill.getLength() > 1) {
      $.ajax({
        type: "POST",
        url: e.target.action,
        data: $(e.target).serialize(),
        success: function(res) {
          appendMessage(messages, res.content, res.class, res.author_name)
          quill.setContents(null)
          scrollMessagesToBottom()
        }
      });
    }
  } else {
    alert("Something went wrong. Refresh and try again")
  }
})

const appendMessage = (container, content, className, userName) => {
  container.append(`
    <div>${userName}</div>
    <div class="${className}">
      ${content}
    </div>
    <br/>
  `)
}

const scrollMessagesToBottom = () => {
  const messagesContainer = $(".message_center .message_center__messages");
  if (messagesContainer[0]) {
    messagesContainer.scrollTop(messagesContainer[0].scrollHeight);
  }
}

scrollMessagesToBottom()

$(".message_center__star").on("click", (e) => {
  url = $(e.target).data("url")

  $.ajax({
    type: "POST",
    url: url,
    success: function(res) {
      console.log("RES", res)
      if (res.starred) {
        $(e.target).removeClass("far")
        $(e.target).addClass("fas")
      } else {
        $(e.target).removeClass("fas")
        $(e.target).addClass("far")
      }
    }
  });
})