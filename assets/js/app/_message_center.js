$(".message_center__challenge_filter").on("change", function() {
  this.form.submit()
})

$(".message_center__message_form .js-message-center-new-message").on("click", (e) => {
  e.preventDefault()

  const messageForm = $(".message_center__message_form")
  const actionValue = $(e.target).val()

  messageForm.data("action", actionValue)
  messageForm.submit()
})

$(".message_center__message_form").on("submit", (e) => {
  e.preventDefault()

  const messages = $(".message_center__messages")
  const quill = $(".message_center .rt-textarea").data("quill")

  const action = encodeURIComponent($(e.target).data("action"))
  const formData = `${$(e.target).serialize()}&message[status]=${action}`

  if (quill) {
    if (quill.getLength() > 1) {
      $.ajax({
        type: "POST",
        url: e.target.action,
        data: formData,
        success: function(res) {
          switch (res.status) {
            case "sent":
              handleMessageSent(res, e.target, messages, quill);
              break;

            case "draft":
              handleMessageDraft(res, e.target);
              break;
          }
        }
      });
    }
  } else {
    alert("Something went wrong. Refresh and try again")
  }
})

const handleMessageSent = (res, form, messages, quill) => {
  appendMessage(messages, res.content, res.class, res.author_name)
  quill.setContents(null)
  scrollMessagesToBottom()
  removeMessageIdQueryParam()
  $('#message_id').remove()
}

const handleMessageDraft = (res, form) => {
  if ($("#message_id").length === 0) {
    $(form).append(`<input id='message_id' name='message[id]' type='hidden' value=${res.id}>`)
  }
  addMessageIdQueryParam(res.id)
  alert("Message saved as draft")
}

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

$(".message_center__star").on("keydown", (e) => {
  if (e.keyCode == 13 || e.keyCode == 32) {
    toggleStar(e)
  }
})

$(".message_center__star").on("click", (e) => {
  toggleStar(e)
})

const toggleStar = (e) => {
  e.stopPropagation()

  const url = $(e.target).data("url")

  $.ajax({
    type: "POST",
    url: url,
    success: function(res) {
      if (res.starred) {
        $(e.target).removeClass("far")
        $(e.target).addClass("fas")
      } else {
        $(e.target).removeClass("fas")
        $(e.target).addClass("far")
      }
    }
  });

}

const removeMessageIdQueryParam = () => {
  history.replaceState && history.replaceState(
    null, '', location.pathname + location.search.replace(/[\?&]message_id=[^&]+/, '').replace(/^&/, '?')
  );
}

const addMessageIdQueryParam = (id) => {
  history.replaceState && history.replaceState(
    null, '', location.pathname + `?message_id=${id}`
  );
}

// Multi submission message table functionality
$(document).ready(() => {
  const checkMultiSubmissionButtonStatus = () => {
    if (checkForSubmissionIDCheckboxes() || checkForHiddenSubmissionIDInputs()) {
      $(".js-multi-submission-msg-btn").prop("disabled", false)
    } else {
      $(".js-multi-submission-msg-btn").prop("disabled", true)
    }
  }

  const checkForSubmissionIDCheckboxes = () => {
    return $(".js-table-row-select").is(":checked")
  }

  const checkForHiddenSubmissionIDInputs = () => {
    return $("input[name='sid[]'][type='hidden']").length > 0
  }

  checkMultiSubmissionButtonStatus()

  $(".submission-management-table-body .js-table-row-select").on("click", e => {
    checkMultiSubmissionButtonStatus()
  })
})