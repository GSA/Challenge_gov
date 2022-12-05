defmodule Web.MessageContextView do
  use Web, :view

  alias ChallengeGov.MessageContexts
  alias ChallengeGov.Repo
  alias ChallengeGov.Submissions

  alias Web.AccountView
  alias Web.ChallengeView
  alias Web.FormView
  alias Web.SharedView

  def message_class(user, message) do
    if message.author_id == user.id do
      "message_center__message message_center__message--self"
    else
      "message_center__message"
    end
  end

  def display_audience(%{role: "solver"}, message_context = %{context: "solver"}) do
    message_context.audience
    |> String.replace("_", " ")
    |> String.capitalize()
  end

  def display_audience(_user, message_context = %{context: "solver"}) do
    solver = MessageContexts.get_context_record(message_context)

    AccountView.full_name(solver)
  end

  def display_audience(_user, message_context) do
    message_context.audience
    |> String.replace("_", " ")
    |> String.capitalize()
  end

  def display_multi_submission_titles(submission_ids) do
    submission_ids
    |> Enum.map_join(
      ", ",
      fn submission_id ->
        {:ok, submission} = Submissions.get(submission_id)
        submission.title
      end
    )
  end

  def display_challenge_title_link(message_context, user \\ nil)

  def display_challenge_title_link(message_context = %{context: "challenge"}, user) do
    challenge = MessageContexts.get_context_record(message_context) || %{title: ""}

    build_link(user, challenge)
  end

  def display_challenge_title_link(message_context = %{context: "solver"}, user) do
    message_context = Repo.preload(message_context, [:parent])
    challenge = MessageContexts.get_context_record(message_context.parent) || %{title: ""}

    build_link(user, challenge)
  end

  defp build_link(_user, %{title: _title, id: nil}),
    do: nil

  defp build_link(user, challenge = %{title: title, id: _id}),
    do:
      link(title,
        to: challenge_url(user, challenge)
      )

  defp build_link(_user, _),
    do: nil

  def challenge_url(%{role: "solver"}, challenge), do: ChallengeView.public_details_url(challenge)

  def challenge_url(_user, %{id: id}),
    do: Routes.challenge_path(Web.Endpoint, :show, id)

  def challenge_url(_user, _), do: nil

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

  def display_message_snippet(message) do
    SharedView.render_safe_html(message.content)
  end

  defp get_last_message_content(%{last_message: nil}), do: nil
  defp get_last_message_content(%{last_message: last_message}), do: last_message.content

  def maybe_unread_class(%{read: true}), do: "message_center__row--read"
  def maybe_unread_class(%{read: false}), do: "message_center__row--unread"

  def maybe_render_audience_header(%{role: "solver"}), do: nil
  def maybe_render_audience_header(_user), do: content_tag(:th, "Audience")

  def maybe_render_audience_column(%{role: "solver"}, _message_context), do: nil

  def maybe_render_audience_column(user, message_context),
    do: content_tag(:td, display_audience(user, message_context))

  def render_new_message_button(_conn, %{role: "solver"}), do: nil

  def render_new_message_button(conn, _user) do
    link("New Message",
      to: Routes.message_context_path(conn, :new, context: "challenge"),
      class: "btn btn-primary me-3"
    )
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
