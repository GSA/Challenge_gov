defmodule Web.SubmissionView do
  use Web, :view

  alias ChallengeGov.Accounts
  alias ChallengeGov.Challenges
  alias ChallengeGov.Submissions

  alias Web.ChallengeView
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

  def phase_number(submission) do
    if submission.challenge.is_multi_phase do
      total_num_phases = Enum.count(submission.challenge.phases)

      phase_num =
        Enum.find_index(
          submission.challenge.phases,
          fn phase -> phase.id === submission.phase.id end
        )

      content_tag :p, class: "challenge-tile__info", aria_label: "Challenge title" do
        content_tag :span do
          "Phase #{phase_num + 1} of #{total_num_phases}"
        end
      end
    end
  end

  def close_header(end_date) do
    now = Timex.now()

    case Timex.compare(end_date, now) do
      1 ->
        content_tag(:span, "Closes")

      tc when tc == -1 or tc == 0 ->
        content_tag(:span, "CLOSED", class: "text-bold")
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

  def review_verified_column_content(true), do: "yes"

  def review_verified_column_content(_review_verified), do: "no"

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

  def submission_edit_link(conn, submission, user, opts \\ []) do
    case Submissions.is_editable?(user, submission) do
      true ->
        link(opts[:label] || "Edit",
          to: Routes.submission_path(conn, :edit, submission.id),
          class: "btn btn-link float-right"
        )

      false ->
        nil
    end
  end

  def submit_button(conn, submission, user, opts \\ []) do
    case Submissions.is_editable?(user, submission) && submission.status !== "submitted" do
      true ->
        link(opts[:label] || "Submit",
          to: Routes.submission_path(conn, :submit, submission.id),
          method: :put,
          class: "btn btn-primary float-right"
        )

      false ->
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
          ChallengeView.public_details_url(challenge)

        action === :edit or action === :update or action === :submit ->
          Routes.submission_path(conn, :index)
      end

    link("Cancel", to: route, class: "btn btn-link")
  end

  def accept_terms(_conn, form, user, challenge) do
    # show for solvers even on editing
    if Accounts.is_solver?(user) do
      content_tag(:div, class: "form-group") do
        content_tag(:div, class: "col") do
          [
            label(form, :terms_accepted) do
              [
                checkbox(form, :terms_accepted,
                  class: FormView.form_group_classes(form, :terms_accepted)
                ),
                " I have read the ",
                link("rules, terms and conditions ",
                  to: ChallengeView.public_details_url(challenge, tab: "rules"),
                  target: "_blank"
                ),
                " of this challenge",
                error_tag(form, :terms_accepted)
              ]
            end
          ]
        end
      end
    end
  end

  def verify_review(form, user_id, submission) do
    %{
      submitter_id: submitter_id,
      manager_id: manager_id,
      review_verified: review_verified
    } = submission

    if submitter_id == user_id and (!!manager_id and !review_verified) do
      content_tag(:div) do
        content_tag(:div, class: "col") do
          [
            label(form, :review_verified) do
              [
                checkbox(form, :review_verified,
                  class: FormView.form_group_classes(form, :review_verified)
                ),
                " I have reviewed the submission and verify it is accurate",
                error_tag(form, :review_verified)
              ]
            end
          ]
        end
      end
    end
  end

  def save_draft_button(data) do
    if Submissions.has_not_been_submitted?(data) do
      submit("Save draft",
        name: "action",
        value: "draft",
        class: "btn btn-outline-secondary me-2 float-right",
        formnovalidate: true
      )
    end
  end
end
