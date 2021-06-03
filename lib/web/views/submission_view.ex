defmodule Web.SubmissionView do
  use Web, :view

  alias ChallengeGov.Accounts
  alias ChallengeGov.Challenges
  alias ChallengeGov.Submissions

  alias Web.DocumentView
  alias Web.FormView
  alias Web.SharedView

  def solver_field(form, user, data) do
    content_tag :div, class: FormView.form_group_classes(form, :solver_addr) do
      [
        label(form, :solver_addr, class: "col-md-4") do
          [
            "Solver ",
            content_tag(:span, "*", class: "required")
          ]
        end,
        content_tag(:div, class: "col") do
          [
            select(
              form,
              :solver_addr,
              Enum.map(
                Accounts.all_solvers_for_select(),
                &{"#{&1.email} (#{&1.first_name} #{&1.last_name})", &1.email}
              ),
              class: "form-control",
              disabled: !Accounts.has_admin_access?(user),
              value: persist_solver_email_on_edit(data)
            ),
            error_tag(form, :solver_addr)
          ]
        end
      ]
    end
  end

  def persist_solver_email_on_edit(data) do
    if data.submitter, do: data.submitter.email, else: ""
  end

  def name_link(conn, submission, query_params \\ []) do
    link(submission.title,
      to: Routes.submission_path(conn, :show, submission.id, query_params)
    )
  end

  def name_link_url(conn, submission) do
    link(submission.title,
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

  def multi_phase_column_header(conn, challenge, phase, sort, filter, sort_name, column_name) do
    if Challenges.is_multi_phase?(challenge) do
      sortable_managed_header(conn, challenge, phase, sort, filter, sort_name, column_name)
    end
  end

  def multi_phase_column_content(challenge, content) do
    if Challenges.is_multi_phase?(challenge) do
      content_tag(:td, content)
    end
  end

  def status_display_name(submission) do
    Submissions.status_label(submission.status)
  end

  def submission_delete_link(conn, submission, user, opts \\ []) do
    case Submissions.allowed_to_delete(user, submission) do
      {:ok, submission} ->
        link(opts[:label] || "Delete",
          to: Routes.submission_path(conn, :delete, submission.id),
          method: :delete,
          class: "btn btn-link text-danger",
          data: [confirm: "Are you sure you want to delete this submission?"]
        )

      {:error, :not_permitted} ->
        nil
    end
  end

  def cancel_button(conn, action, challenge, phase, user, _opts \\ []) do
    route =
      cond do
        Accounts.has_admin_access?(user) ->
          Routes.challenge_phase_managed_submission_path(
            conn,
            :managed_submissions,
            challenge.id,
            phase.id
          )

        action === :new or action === :create ->
          Routes.public_challenge_details_path(conn, :index, challenge.id)

        action === :edit or action === :update or action === :submit ->
          Routes.submission_path(conn, :index)
      end

    link("Cancel", to: route, class: "btn btn-link")
  end

  def accept_terms(conn, form, submission_id, user_id, challenge) do
    if is_nil(submission_id) or submission_id == user_id do
      content_tag(:div) do
        [
            label(form, :terms_accepted) do
              [
                checkbox(form, :terms_accepted, class: FormView.form_group_classes(form, :terms_accepted)),
                " I have read the ",
                link("rules, terms and conditions ", to: Routes.public_challenge_details_path(conn, :index, challenge.id, "rules"), target: "_blank"),
                " of this challenge",
                error_tag(form, :terms_accepted)
              ]
            end
        ]
      end
    end
  end

  def save_draft_button(data) do
    if Submissions.has_not_been_submitted?(data) do
      submit("Save draft",
        name: "action",
        value: "draft",
        class: "btn btn-outline-secondary mr-2 float-right",
        formnovalidate: true
      )
    end
  end
end
