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

  def render_select_for_judging_button(conn, challenge, solution) do
    {text, status_to_set} =
      case solution.judging_status do
        "selected" ->
          {"Selected", "unselect"}

        "not_selected" ->
          {"Select", "select"}

        _ ->
          {"Error", "error"}
      end

    link(text,
      to:
        Routes.challenge_solution_path(
          conn,
          :update_judging_status,
          challenge.id,
          solution.id,
          status_to_set
        ),
      method: :put
    )
  end
end
