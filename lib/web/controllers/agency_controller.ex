defmodule Web.AgencyController do
  use Web, :controller

  alias ChallengeGov.Accounts
  alias ChallengeGov.Agencies

  plug(Web.Plugs.FetchPage, [per: 12] when action in [:index])

  action_fallback(Web.FallbackController)

  def index(conn, _params) do
    %{page: page, per: per} = conn.assigns
    %{page: teams, pagination: pagination} = Agencies.all(page: page, per: per)

    conn
    |> assign(:teams, teams)
    |> assign(:pagination, pagination)
    |> render("index.html")
  end

  def show(conn, %{"id" => id}) do
    with {:ok, team} <- Agencies.get(id) do
      conn
      |> assign(:team, team)
      |> assign(:accounts, Accounts.for_inviting_to())
      |> render("show.html")
    end
  end

  def new(conn, _params) do
    conn
    |> assign(:changeset, Agencies.new())
    |> render("new.html")
  end

  def create(conn, %{"team" => params}) do
    %{current_user: user} = conn.assigns

    case Agencies.create(user, params) do
      {:ok, team} ->
        conn
        |> put_flash(:info, "Team created!")
        |> redirect(to: Routes.team_path(conn, :show, team.id))

      {:error, changeset} ->
        conn
        |> assign(:changeset, changeset)
        |> put_flash(:error, "There was an issue creating the team")
        |> put_status(422)
        |> render("new.html")
    end
  end
end
