defmodule Web.Admin.TeamController do
  use Web, :controller

  alias IdeaPortal.Teams

  plug(Web.Plugs.FetchPage when action in [:index])

  action_fallback(Web.Admin.FallbackController)

  def index(conn, _params) do
    %{page: page, per: per} = conn.assigns
    %{page: teams, pagination: pagination} = Teams.all(page: page, per: per)

    conn
    |> assign(:teams, teams)
    |> assign(:pagination, pagination)
    |> render("index.html")
  end

  def show(conn, %{"id" => id}) do
    with {:ok, team} <- Teams.get(id) do
      conn
      |> assign(:team, team)
      |> assign(:members, team.members)
      |> render("show.html")
    end
  end

  def edit(conn, %{"id" => id}) do
    with {:ok, team} <- Teams.get(id) do
      conn
      |> assign(:team, team)
      |> assign(:changeset, Teams.edit(team))
      |> render("edit.html")
    end
  end

  def update(conn, %{"id" => id, "team" => params}) do
    {:ok, team} = Teams.get(id)

    case Teams.update(team, params) do
      {:ok, team} ->
        conn
        |> put_flash(:info, "Team updated!")
        |> redirect(to: Routes.admin_team_path(conn, :show, team.id))

      {:error, changeset} ->
        conn
        |> assign(:team, team)
        |> assign(:changeset, changeset)
        |> put_flash(:error, "Team could not be saved")
        |> put_status(422)
        |> render("edit.html")
    end
  end

  def delete(conn, %{"id" => id}) do
    with {:ok, team} <- Teams.get(id),
         {:ok, _team} <- Teams.delete(team) do
      conn
      |> put_flash(:info, "Team deleted!")
      |> redirect(to: Routes.admin_team_path(conn, :index))
    end
  end
end
