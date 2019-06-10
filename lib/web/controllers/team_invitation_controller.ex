defmodule Web.TeamInvitationController do
  use Web, :controller

  alias IdeaPortal.Accounts
  alias IdeaPortal.Teams

  action_fallback(Web.FallbackController)

  def index(conn, params = %{"team_id" => team_id}) do
    query = Map.get(params, "q", "")

    with {:ok, team} <- Teams.get(team_id) do
      conn
      |> assign(:team, team)
      |> assign(:accounts, Accounts.for_inviting_to(search: query))
      |> render("index.json")
    end
  end

  def create(conn, %{"team_id" => team_id, "user_id" => user_id}) do
    %{current_user: user} = conn.assigns

    with {:ok, team} <- Teams.get(team_id),
         true <- Teams.member?(team, user),
         {:ok, invitee} <- Accounts.public_get(user_id),
         {:ok, _member} <- Teams.invite_member(team, user, invitee) do
      conn
      |> put_flash(:info, "User was invited")
      |> redirect(to: Routes.team_path(conn, :show, team.id))
    else
      _ ->
        conn
        |> put_flash(:error, "There was an error inviting the user")
        |> redirect(to: Routes.team_path(conn, :show, team_id))
    end
  end

  def accept(conn, %{"team_id" => team_id}) do
    %{current_user: user} = conn.assigns

    with {:ok, team} <- Teams.get(team_id),
         {:ok, _member} <- Teams.accept_invite(team, user) do
      conn
      |> put_flash(:info, "You are part of the team now")
      |> redirect(to: Routes.team_path(conn, :show, team.id))
    else
      _ ->
        conn
        |> put_flash(:error, "There was an error accepting the invite")
        |> redirect(to: Routes.team_path(conn, :show, team_id))
    end
  end

  def reject(conn, %{"team_id" => team_id}) do
    %{current_user: user} = conn.assigns

    with {:ok, team} <- Teams.get(team_id),
         {:ok, _member} <- Teams.reject_invite(team, user) do
      conn
      |> put_flash(:info, "You have rejected the invite")
      |> redirect(to: Routes.team_path(conn, :index))
    else
      _ ->
        conn
        |> put_flash(:error, "There was an error rejecting the invite")
        |> redirect(to: Routes.team_path(conn, :index))
    end
  end
end
