defmodule Web.SolutionView do
  use Web, :view

  alias ChallengeGov.Accounts
  alias ChallengeGov.Challenges
  alias ChallengeGov.Solutions
  alias Web.FormView
  alias Web.SharedView
  alias Web.DocumentView
  alias Web.PhaseView

  def name_link(conn, solution, query_params \\ []) do
    link(solution.title || "Solution #{solution.id}",
      to: Routes.solution_path(conn, :show, solution.id, query_params)
    )
  end

  def name_link_url(conn, solution) do
    link(solution.title || "Solution #{solution.id}",
      to: Routes.solution_url(conn, :show, solution.id)
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
      link(to: Routes.solution_path(conn, :index, filter: filter, sort: sort_values)) do
        content_tag :div do
          [
            content_tag(:span, label),
            content_tag(:i, "", class: "fa " <> sort_icon)
          ]
        end
      end
    end
  end

  def status_display_name(solution) do
    Solutions.status_label(solution.status)
  end

  def solution_delete_link(conn, solution, user, opts \\ []) do
    if (user.role == "solver" and solution.status == "draft") or
         Accounts.has_admin_access?(user) do
      link(opts[:label] || "Delete",
        to: Routes.solution_path(conn, :delete, solution.id),
        method: :delete,
        class: "btn btn-link text-danger",
        data: [confirm: "Are you sure you want to delete this solution?"]
      )
    end
  end

  def cancel_button(conn, action, challenge, _opts \\ []) do
    route =
      case action do
        a when a === :new or a === :create ->
          Routes.public_challenge_details_path(conn, :index, challenge.id)

        a when a === :edit or a === :update or a === :submit ->
          Routes.solution_path(conn, :index)
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

  def render_solution_header_text(challenge, phase, solution) do
    if length(challenge.phases) > 1 do
      [
        "Phase ",
        content_tag(:i, phase.title),
        " for challenge ",
        content_tag(:i, challenge.title || challenge.id),
        " submission #{solution.id} details"
      ]
    else
      [
        "Challenge ",
        content_tag(:i, challenge.title || challenge.id),
        " submission #{solution.id} details"
      ]
    end
  end

  def render("judging_status.json", %{
        conn: conn,
        challenge: challenge,
        phase: phase,
        solution: solution,
        updated_solution: updated_solution,
        filter: filter
             }) do
    IO.inspect("rendering judging status")
    PhaseView.get_judging_status_button_values(
      conn,
      challenge,
      phase,
      updated_solution,
      solution.judging_status,
      filter
    )
  end
end
