defmodule Web.PhaseView do
  use Web, :view

  alias ChallengeGov.Phases
  alias Web.SharedView

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

  # TODO: Refactor to be more generic
  # Example: Take a path with existing query params and append sort after and no longer need to pass filter
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

  # TODO: Phase will be used here to determine wording on the final phase of winners/awardees
  def render_judging_status_column_header(_phase, %{"judging_status" => "selected"}),
    do: "Select for next phase"

  def render_judging_status_column_header(_phase, %{"judging_status" => "winner"}),
    do: "Selected for next phase"

  def render_judging_status_column_header(_phase, %{"judging_status" => "all"}),
    do: "Selected for judging"

  def render_judging_status_column_header(_phase, _filter), do: "Selected for judging"

  def render_select_for_judging_button(conn, solution, filter) do
    %{text: text, route: route, class: class} =
      get_judging_status_button_values(conn, solution, nil, filter)

    link(text, to: route, class: class, role: "button", disabled: false)
  end

  def get_judging_status_button_values(
        conn,
        solution = %{judging_status: "selected"},
        prev_status,
        filter = %{"judging_status" => "winner"}
      ) do
    %{
      text: "Undo",
      status: solution.judging_status,
      prev_status: prev_status,
      route:
        Routes.solution_path(conn, :update_judging_status, solution.id, "winner", filter: filter),
      class: "btn btn-primary btn-xs js-select-for-judging"
    }
  end

  def get_judging_status_button_values(
        conn,
        solution = %{judging_status: "winner"},
        prev_status,
        filter = %{"judging_status" => "winner"}
      ) do
    %{
      text: "Move back to judging",
      status: solution.judging_status,
      prev_status: prev_status,
      route:
        Routes.solution_path(conn, :update_judging_status, solution.id, "selected", filter: filter),
      class: "btn btn-secondary btn-xs js-select-for-judging"
    }
  end

  def get_judging_status_button_values(
        conn,
        solution = %{judging_status: "selected"},
        prev_status,
        filter = %{"judging_status" => "selected"}
      ) do
    %{
      text: "Add",
      status: solution.judging_status,
      prev_status: prev_status,
      route:
        Routes.solution_path(conn, :update_judging_status, solution.id, "winner", filter: filter),
      class: "btn btn-primary btn-xs js-select-for-judging"
    }
  end

  def get_judging_status_button_values(
        conn,
        solution = %{judging_status: "winner"},
        prev_status,
        filter = %{"judging_status" => "selected"}
      ) do
    %{
      text: "Selected",
      status: solution.judging_status,
      prev_status: prev_status,
      route:
        Routes.solution_path(conn, :update_judging_status, solution.id, "selected", filter: filter),
      class: "btn btn-secondary btn-xs js-select-for-judging"
    }
  end

  def get_judging_status_button_values(
        conn,
        solution = %{judging_status: "not_selected"},
        prev_status,
        filter
      ) do
    %{
      text: "Add",
      status: solution.judging_status,
      prev_status: prev_status,
      route:
        Routes.solution_path(conn, :update_judging_status, solution.id, "selected", filter: filter),
      class: "btn btn-primary btn-xs js-select-for-judging"
    }
  end

  def get_judging_status_button_values(
        conn,
        solution = %{judging_status: "selected"},
        prev_status,
        filter
      ) do
    %{
      text: "Selected",
      status: solution.judging_status,
      prev_status: prev_status,
      route:
        Routes.solution_path(conn, :update_judging_status, solution.id, "not_selected",
          filter: filter
        ),
      class: "btn btn-secondary btn-xs js-select-for-judging"
    }
  end

  def get_judging_status_button_values(
        conn,
        solution = %{judging_status: "winner"},
        prev_status,
        filter
      ) do
    %{
      text: "Selected (Awardee)",
      status: solution.judging_status,
      prev_status: prev_status,
      route:
        Routes.solution_path(conn, :update_judging_status, solution.id, "not_selected",
          filter: filter
        ),
      class: "btn btn-secondary btn-xs js-select-for-judging"
    }
  end

  # Submission filter tab functions
  def render_submission_filter_tabs(conn, phase, filter) do
    content_tag(:ul, class: "submission-filter nav nav-tabs") do
      [
        render_submission_filter_tab(conn, phase, filter, "all"),
        render_submission_filter_tab(conn, phase, filter, "selected"),
        render_submission_filter_tab(conn, phase, filter, "winner")
      ]
    end
  end

  def render_submission_filter_tab(conn, phase, filter, filter_key) do
    judging_status_filter_value = Map.get(filter, "judging_status", "all")
    filter = Map.put(filter, "judging_status", filter_key)

    content_tag(:li, class: "nav-item") do
      link(filter_tab_content(phase, filter, filter_key),
        to:
          Routes.challenge_phase_path(conn, :show, phase.challenge.id, phase.id, filter: filter),
        class: filter_tab_class(judging_status_filter_value, filter_key)
      )
    end
  end

  def filter_tab_content(phase, filter, filter_key) do
    content_tag(:div, class: "submission-filter__tab submission-filter__tab--#{filter_key}") do
      [
        filter_tab_text(phase, filter_key),
        filter_tab_count(phase, filter)
      ]
    end
  end

  # TODO: Use phase here to determine alternate filter tab text in some cases for winners/awardees
  def filter_tab_text(_phase, "all"),
    do: content_tag(:span, "All submissions", class: "submission-filter__text mr-1")

  def filter_tab_text(_phase, "selected"),
    do: content_tag(:span, "Selected for judging", class: "submission-filter__text mr-1")

  def filter_tab_text(_phase, "winner"),
    do: content_tag(:span, "Winners", class: "submission-filter__text mr-1")

  def filter_tab_text(_phase, _filter_key),
    do: content_tag(:span, "Undefined", class: "submission-filter__text mr-1")

  def filter_tab_count(phase, filter) do
    [
      "(",
      content_tag(:span, Phases.solution_count(phase, filter), class: "submission-filter__count"),
      ")"
    ]
  end

  def filter_tab_class("winner", "winner"), do: "nav-link active"
  def filter_tab_class("selected", "selected"), do: "nav-link active"
  def filter_tab_class("all", "all"), do: "nav-link active"
  def filter_tab_class(_filter, _filter_key), do: "nav-link"
end
