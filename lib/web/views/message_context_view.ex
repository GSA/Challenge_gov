defmodule Web.MessageContextView do
  use Web, :view

  alias ChallengeGov.MessageContexts

  alias Web.AccountView
  alias Web.FormView
  alias Web.SharedView

  def message_class(user, message) do
    if message.author_id == user.id do
      "message_center__message message_center__message--self"
    else
      "message_center__message"
    end
  end

  def display_audience(message_context) do
    message_context.audience
    |> Enum.map(&String.capitalize(&1))
    |> Enum.join(", ")
  end

  def display_challenge_title_link(message_context) do
    challenge = MessageContexts.get_context_record(message_context) || %{title: ""}

    link(challenge.title,
      to: Routes.challenge_path(Web.Endpoint, :show, message_context.context_id)
    )
  end

  def display_last_message_snippet(message_context) do
    last_message =
      message_context.messages
      |> Enum.sort_by(& &1.inserted_at)
      |> Enum.at(-1) || %{content: ""}

    SharedView.render_safe_html(last_message.content)
  end

  def render_star(message_context_status) do
    class = if message_context_status.starred, do: "fas", else: "far"

    content_tag(:div, "",
      data: [
        url:
          Routes.api_message_context_status_path(
            Web.Endpoint,
            :toggle_starred,
            message_context_status.id
          )
      ],
      class: "message_center__star fa-star #{class}"
    )
  end

  def filter_active_class(conn, _route) do
    _filter = Map.get(conn.params, "filter", %{})

    "active"
  end
end
