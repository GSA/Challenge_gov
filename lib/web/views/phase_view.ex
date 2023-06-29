defmodule Web.PhaseView do
  use Web, :view

  alias ChallengeGov.Accounts
  alias ChallengeGov.Challenges
  alias ChallengeGov.Phases
  alias Web.SharedView
  alias Web.SubmissionView

  def render_manage_submissions_button(conn, user, challenge, phase) do
    if Accounts.has_admin_access?(user) do
      content_tag(:span, class: "submission-filter__helper-text p-3", style: "display: inline;") do
        link("Add solver submission ->",
          to:
            Routes.challenge_phase_managed_submission_path(
              conn,
              :managed_submissions,
              challenge.id,
              phase.id
            )
        )
      end
    end
  end

  def render_message_submissions_button(action) do
    content_tag(:span, class: "submission-filter__helper-text p-3", style: "display: inline;") do
      submit("Message solvers",
        formaction: action,
        class: "btn btn-primary mb-3 js-multi-submission-msg-btn",
        disabled: true
      )
    end
  end

  def status(phase) do
    cond do
      Phases.is_past?(phase) ->
        content_tag(:span, "Closed to submissions")

      Phases.is_current?(phase) ->
        content_tag(:span, "Open to submissions")

      Phases.is_future?(phase) ->
        [
          content_tag(:span, "Opens on "),
          SharedView.local_datetime_tag(phase.start_date, "span")
        ]
    end
  end

  def submission_period_text(phase) do
    cond do
      Phases.is_past?(phase) ->
        [
          content_tag(:span, "Closed on "),
          SharedView.local_datetime_tag(phase.end_date, "span")
        ]

      Phases.is_current?(phase) ->
        [
          content_tag(:span, "Opened on "),
          SharedView.local_datetime_tag(phase.start_date, "span")
        ]

      Phases.is_future?(phase) ->
        [
          content_tag(:span, "Opens on "),
          SharedView.local_datetime_tag(phase.start_date, "span")
        ]
    end
  end

  def sortable_header(conn, sort, filter, column, label, phase) do
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
          Routes.challenge_phase_path(conn, :show, phase.challenge.id, phase.id,
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

  def render_judging_status_column_header(challenge, phase, %{"judging_status" => "selected"}) do
    if next_phase_closed?(challenge, phase) do
      "Select for next phase"
    else
      "Select as awardee"
    end
  end

  def render_judging_status_column_header(challenge, phase, %{"judging_status" => "winner"}) do
    if next_phase_closed?(challenge, phase) do
      "Selected for next phase"
    else
      "Selected as awardee"
    end
  end

  def render_judging_status_column_header(_challenge, _phase, %{"judging_status" => "all"}),
    do: "Selected for judging"

  def render_judging_status_column_header(_challenge, _phase, _filter), do: "Selected for judging"

  def next_phase_closed?(challenge, phase) do
    case Challenges.next_phase(challenge, phase) do
      {:ok, phase} ->
        !phase.open_to_submissions

      {:error, :not_found} ->
        false
    end
  end

  def render_select_for_judging_button(conn, challenge, phase, submission, filter) do
    %{text: text, route: route, class: class} =
      get_judging_status_button_values(conn, challenge, phase, submission, nil, filter)

    disabled = judging_button_disabled(phase)

    link(text,
      to: route,
      class: maybe_judging_button_disabled_class(disabled, class),
      role: "button",
      disabled: disabled
    )
  end

  defp judging_button_disabled(phase) do
    !Phases.is_past?(phase)
  end

  defp maybe_judging_button_disabled_class(true, class), do: class <> " disabled "
  defp maybe_judging_button_disabled_class(false, class), do: class

  defp judging_status_selected_winner(map, conn, submission, filter) do
    Map.merge(
      map,
      %{
        text: "Undo",
        route: get_judging_status_route(conn, submission, "winner", filter),
        class: map.class <> "btn-primary btn-short"
      }
    )
  end

  defp judging_status_winner_winner(map, conn, submission, filter) do
    Map.merge(
      map,
      %{
        text: "Move back to judging",
        route: get_judging_status_route(conn, submission, "selected", filter),
        class: map.class <> "btn-secondary btn-long"
      }
    )
  end

  defp judging_status_selected_selected(map, conn, submission, filter) do
    Map.merge(
      map,
      %{
        text: "+ Add",
        route: get_judging_status_route(conn, submission, "winner", filter),
        class: map.class <> "btn-primary btn-short"
      }
    )
  end

  defp judging_status_winner_selected(map, conn, submission, filter) do
    Map.merge(
      map,
      %{
        text: "Selected",
        route: get_judging_status_route(conn, submission, "selected", filter),
        class: map.class <> "btn-secondary btn-short"
      }
    )
  end

  defp judging_status_not_selected_any(map, conn, submission, filter) do
    Map.merge(
      map,
      %{
        text: "+ Add",
        route: get_judging_status_route(conn, submission, "selected", filter),
        class: map.class <> "btn-primary btn-short"
      }
    )
  end

  defp judging_status_selected_any(map, conn, submission, filter) do
    Map.merge(
      map,
      %{
        text: "Selected",
        route: get_judging_status_route(conn, submission, "not_selected", filter),
        class: map.class <> "btn-secondary btn-short"
      }
    )
  end

  defp judging_status_winner_any(map, conn, challenge, phase, submission, filter) do
    text =
      if next_phase_closed?(challenge, phase),
        do: "Selected (next phase)",
        else: "Selected (awardee)"

    Map.merge(
      map,
      %{
        text: text,
        route: get_judging_status_route(conn, submission, "not_selected", filter),
        class: map.class <> "btn-secondary btn-long"
      }
    )
  end

  defp get_judging_status_route(conn, submission, judging_status, filter) do
    Routes.api_submission_path(conn, :update_judging_status, submission.id, judging_status,
      filter: filter
    )
  end

  def get_judging_status_button_values(conn, challenge, phase, submission, prev_status, filter) do
    map = %{
      status: submission.judging_status,
      prev_status: prev_status,
      class: "btn btn-xs js-select-for-judging "
    }

    case {submission.judging_status, filter["judging_status"]} do
      {"selected", "winner"} ->
        judging_status_selected_winner(map, conn, submission, filter)

      {"winner", "winner"} ->
        judging_status_winner_winner(map, conn, submission, filter)

      {"selected", "selected"} ->
        judging_status_selected_selected(map, conn, submission, filter)

      {"winner", "selected"} ->
        judging_status_winner_selected(map, conn, submission, filter)

      {"not_selected", _} ->
        judging_status_not_selected_any(map, conn, submission, filter)

      {"selected", _} ->
        judging_status_selected_any(map, conn, submission, filter)

      {"winner", _} ->
        judging_status_winner_any(map, conn, challenge, phase, submission, filter)
    end
  end

  # Submission filter tab functions
  def render_submission_filter_tabs(conn, challenge, phase, filter) do
    content_tag(:ul, class: "submission-filter nav nav-tabs") do
      [
        render_submission_filter_tab(conn, challenge, phase, filter, "all"),
        render_submission_filter_tab(conn, challenge, phase, filter, "selected"),
        render_submission_filter_tab(conn, challenge, phase, filter, "winner")
      ]
    end
  end

  def render_submission_filter_tab(conn, challenge, phase, filter, filter_key) do
    judging_status_filter_value = Map.get(filter, "judging_status", "all")
    filter = Map.put(filter, "judging_status", filter_key)

    content_tag(:li, class: "nav-item") do
      link(filter_tab_content(challenge, phase, filter, filter_key),
        to:
          Routes.challenge_phase_path(conn, :show, phase.challenge.id, phase.id, filter: filter),
        class: filter_tab_class(judging_status_filter_value, filter_key)
      )
    end
  end

  def render_submission_filter_helper_text(challenge, phase, filter) do
    judging_status_filter_value = Map.get(filter, "judging_status", "all")
    next_phase_closed? = next_phase_closed?(challenge, phase)

    [
      content_tag(:div, class: "submission-filter__helper-text p-3 bg-white") do
        submission_filter_helper_text(judging_status_filter_value, next_phase_closed?)
      end,
      submission_filter_winner_note(judging_status_filter_value, next_phase_closed?)
    ]
  end

  defp submission_filter_helper_text("all", _),
    do:
      "Select the submissions from the table below that are approved for judging. Once selected, they will show up in the judging tab."

  defp submission_filter_helper_text("selected", false),
    do:
      "Select the submissions from the table below that are approved as awardees. Once selected, they will show up in the awardee tab."

  defp submission_filter_helper_text("selected", true),
    do:
      "Select the submissions from the table below that are approved for the next phase. Once selected, they will show up in the next phase tab."

  defp submission_filter_helper_text("winner", false),
    do: "The submissions in this table have been selected as awardees."

  defp submission_filter_helper_text("winner", true),
    do:
      "The submissions in this table have been selected to move to the next phase. Please invite the solvers to inform them about the next steps."

  defp submission_filter_winner_note("winner", true) do
    content_tag(:div,
      class: "submission-filter__helper-note px-3 pb-3 bg-white text-bold text-italic"
    ) do
      "Note: Only solvers in this table can submit during the next phase."
    end
  end

  defp submission_filter_winner_note(_, _), do: []

  def render_manage_invite_button(conn, challenge, phase, %{"judging_status" => "winner"}) do
    next_phase_closed? = next_phase_closed?(challenge, phase)

    if next_phase_closed? do
      content_tag(:div, class: "col") do
        content_tag(:div, class: "col p-3") do
          link("Manage invites for next phase",
            to: Routes.submission_invite_path(conn, :index, phase.id),
            class: "btn btn-primary float-right"
          )
        end
      end
    else
      nil
    end
  end

  def render_manage_invite_button(_conn, _challenge, _phase, _filter), do: nil

  def filter_tab_content(challenge, phase, filter, filter_key) do
    content_tag(:div, class: "submission-filter__tab submission-filter__tab--#{filter_key}") do
      [
        filter_tab_text(challenge, phase, filter_key),
        filter_tab_count(phase, filter)
      ]
    end
  end

  def filter_tab_text(_challenge, _phase, "all"),
    do: content_tag(:span, "All submissions", class: "submission-filter__text me-1")

  def filter_tab_text(_challenge, _phase, "selected"),
    do: content_tag(:span, "Selected for judging", class: "submission-filter__text me-1")

  def filter_tab_text(challenge, phase, "winner") do
    text =
      if next_phase_closed?(challenge, phase), do: "Selected for next phase", else: "Awardees"

    content_tag(:span, text, class: "submission-filter__text me-1")
  end

  def filter_tab_text(_challenge, _phase, _filter_key),
    do: content_tag(:span, "Undefined", class: "submission-filter__text me-1")

  def filter_tab_count(phase, filter) do
    [
      "(",
      content_tag(:span, Phases.submission_count(phase, filter), class: "submission-filter__count"),
      ")"
    ]
  end

  def filter_tab_class("winner", "winner"), do: "nav-link active"
  def filter_tab_class("selected", "selected"), do: "nav-link active"
  def filter_tab_class("all", "all"), do: "nav-link active"
  def filter_tab_class(_filter, _filter_key), do: "nav-link"
end
