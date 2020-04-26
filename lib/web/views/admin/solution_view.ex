defmodule Web.Admin.SolutionView do
  use Web, :view

  alias ChallengeGov.Accounts
  alias ChallengeGov.Solutions
  alias Web.Admin.FormView
  alias Web.SharedView

  def name_link(conn, solution) do
    link(solution.title || "Solution #{solution.id}",
      to: Routes.admin_solution_path(conn, :show, solution.id)
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
      link(to: Routes.admin_solution_path(conn, :index, filter: filter, sort: sort_values)) do
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
        to: Routes.admin_solution_path(conn, :delete, solution.id),
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
          Routes.admin_solution_path(conn, :index)
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
end
