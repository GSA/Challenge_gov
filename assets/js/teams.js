import _ from "underscore";
import jquery from "jquery";

let participantTemplate = (account) => {
  let name = account.name;
  let avatarUrl = account.avatar_url;
  let inviteUrl = account.invite_url;

  return `<div class="col-12 col-md-4 col-lg-3">
    <div class="card participant-item">
      <div class="card-body">
        <a href="${inviteUrl}" data-method="post" class="text-center">
          <span class="image-circle"><img src="${avatarUrl}" alt="Avatar" /></span>
          <h3 class="font-regular">${name}</h3>
        </a>
      </div>
    </div>
  </div>`;
}

$(() => {
  let searchUrl = $("#teams-invite").attr("action");

  let keydown = _.debounce((e) => {
    let value = e.target.value;

    if (value.length < 3) {
      return;
    }

    $.ajax(searchUrl, {
      data: {q: e.target.value},
      method: "GET",
      success: (data) => {
        $(".participant-wrapper").empty();
        $(data.collection).each((i, account) => {
          let html = $(participantTemplate(account));
          $(".participant-wrapper").append(html);
        });

        if (data.collection.length === 0) {
          let html = $("<div><p>No participants found</p></div>");
          $(".participant-wrapper").append(html);
        }
      },
    });
  }, 250);

  $("#teams-invite").on("submit", (e) => {
    e.preventDefault();
  });
  $("#teams-invite-member").on("keydown", keydown);
});
