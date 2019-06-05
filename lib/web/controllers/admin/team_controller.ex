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
end
