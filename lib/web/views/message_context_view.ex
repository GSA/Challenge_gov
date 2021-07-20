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

  def display_last_author_name(message_context) do
    last_author = get_last_author(message_context)

    case last_author do
      nil ->
        ""

      author ->
        AccountView.full_name(author)
    end
  end

  def display_last_author_role(message_context) do
    last_author = get_last_author(message_context)

    case last_author do
      nil ->
        ""

      author ->
        AccountView.role_display(author)
    end
  end

  defp get_last_author(%{last_message: nil}), do: nil
  defp get_last_author(%{last_message: last_message}), do: last_message.author

  def display_last_message_snippet(message_context) do
    last_message_content = get_last_message_content(message_context)

    SharedView.render_safe_html(last_message_content)
  end

  defp get_last_message_content(%{last_message: nil}), do: nil
  defp get_last_message_content(%{last_message: last_message}), do: last_message.content

  def maybe_unread_class(%{read: true}), do: "message_center__row--read"
  def maybe_unread_class(%{read: false}), do: "message_center__row--unread"

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
      class: "message_center__star fa-star #{class}",
      alt: "Unarchive",
      tabIndex: 0
    )
  end

  def render_archive_icon(message_context_status = %{archived: true}) do
    link("",
      method: :post,
      to:
        Routes.message_context_status_path(
          Web.Endpoint,
          :unarchive,
          message_context_status.id
        ),
      class: "message_center__archive fas fa-inbox",
      alt: "Unarchive",
      tabIndex: 0
    )
  end

  def render_archive_icon(message_context_status = %{archived: false}) do
    link("",
      method: :post,
      to:
        Routes.message_context_status_path(
          Web.Endpoint,
          :archive,
          message_context_status.id
        ),
      class: "message_center__archive fas fa-archive",
      alt: "Archive",
      tabIndex: 0
    )
  end

  def render_read_icon(message_context_status = %{read: true}) do
    link("",
      method: :post,
      to:
        Routes.message_context_status_path(
          Web.Endpoint,
          :mark_unread,
          message_context_status.id
        ),
      class: "message_center__read fas fa-envelope",
      alt: "Mark unread",
      tabIndex: 0
    )
  end

  def render_read_icon(message_context_status = %{read: false}) do
    link("",
      method: :post,
      to:
        Routes.message_context_status_path(
          Web.Endpoint,
          :mark_read,
          message_context_status.id
        ),
      class: "message_center__read fas fa-envelope-open",
      alt: "Mark read",
      tabIndex: 0
    )
  end

  def filter_active_class(conn, route) do
    filter = Map.get(conn.params, "filter", %{})

    cond do
      Map.get(filter, route) ->
        "btn-primary"

      route == "all" and filter == %{} ->
        "btn-primary"

      true ->
        "btn-link"
    end
  end
end
