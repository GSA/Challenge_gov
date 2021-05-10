defmodule Web.SubmissionView do
  use Web, :view

  alias ChallengeGov.Accounts
  alias ChallengeGov.Challenges
  alias ChallengeGov.Submissions

  alias Web.DocumentView
  alias Web.FormView
  alias Web.SharedView

  def persist_solver_email_on_edit(data) do
    if data.submitter, do: data.submitter.email, else: ""
  end

  def name_link(conn, submission, query_params \\ []) do
    link(submission.title || "Submission #{submission.id}",
      to: Routes.submission_path(conn, :show, submission.id, query_params)
    )
  end

  def name_link_url(conn, submission) do
    link(submission.title || "Submission #{submission.id}",
      to: Routes.submission_url(conn, :show, submission.id)
    )
  end

  def sortable_header(conn, sort, filter, column, label) do
    {sort_icon, sort_values} =
      case Map.get(sort, column) do
        "asc" ->
          {"fa-sort-up", Map.put(%{}, column, :desc)}

        "desc" ->
          {"fa-sort-down", %{}}

        _ ->
          {"fa-sort", Map.put(%{}, column, :asc)}
      end

    content_tag :th do
      link(to: Routes.submission_path(conn, :index, filter: filter, sort: sort_values)) do
        content_tag :div do
          [
            content_tag(:span, label),
            content_tag(:i, "", class: "fa " <> sort_icon)
          ]
        end
      end
    end
  end

  def sortable_managed_header(conn, challenge, phase, sort, filter, column, label) do
    {sort_icon, sort_values} =
      case Map.get(sort, column) do
        "asc" ->
          {"fa-sort-up", Map.put(%{}, column, :desc)}

        "desc" ->
          {"fa-sort-down", %{}}

        _ ->
          {"fa-sort", Map.put(%{}, column, :asc)}
      end

    content_tag :th do
      link(
        to:
          Routes.challenge_phase_managed_submission_path(
            conn,
            :managed_submissions,
            challenge.id,
            phase.id,
            filter: filter,
            sort: sort_values
          )
      ) do
        content_tag :div do
          [
            content_tag(:span, label),
            content_tag(:i, "", class: "fa " <> sort_icon)
          ]
        end
      end
    end
  end

  def status_display_name(submission) do
    Submissions.status_label(submission.status)
  end

  def submission_delete_link(conn, submission, user, opts \\ []) do
    case Submissions.allowed_to_delete?(user, submission) do
      {:ok, submission} ->
        link(opts[:label] || "Delete",
          to: Routes.submission_path(conn, :delete, submission.id),
          method: :delete,
          class: "btn btn-link text-danger",
          data: [confirm: "Are you sure you want to delete this submission?"]
        )
    end
  end

  def cancel_button(conn, action, challenge, _opts \\ []) do
    route =
      case action do
        a when a === :new or a === :create ->
          Routes.public_challenge_details_path(conn, :index, challenge.id)

        a when a === :edit or a === :update or a === :submit ->
          Routes.submission_path(conn, :index)
      end

    link("Cancel", to: route, class: "btn btn-link")
  end

  def save_draft_button() do
    submit("Save draft",
      name: "action",
      value: "draft",
      class: "btn btn-outline-secondary mr-2 float-right",
      formnovalidate: true
    )
  end

  def render_submission_header_text(challenge, phase, submission) do
    if length(challenge.phases) > 1 do
      [
        "Phase ",
        content_tag(:i, phase.title),
        " for challenge ",
        content_tag(:i, challenge.title || challenge.id),
        " submission #{submission.id} details"
      ]
    else
      [
        "Challenge ",
        content_tag(:i, challenge.title || challenge.id),
        " submission #{submission.id} details"
      ]
    end
  end
end
