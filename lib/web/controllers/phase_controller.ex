defmodule Web.PhaseController do
  use Web, :controller

  alias ChallengeGov.Challenges
  alias ChallengeGov.Phases
  alias ChallengeGov.Solutions

  plug Web.Plugs.FetchPage when action in [:show]

  plug Web.Plugs.EnsureRole, [:super_admin, :admin, :challenge_owner]

  def index(conn, %{"challenge_id" => challenge_id}) do
    %{current_user: user} = conn.assigns

    with {:ok, challenge} <- Challenges.get(challenge_id),
         {:ok, challenge} <- Challenges.allowed_to_edit(user, challenge),
         phases <- Phases.all(filter: %{"challenge_id" => challenge.id}) do
      conn
      |> assign(:user, user)
      |> assign(:challenge, challenge)
      |> assign(:phases, phases)
      |> render("index.html")
    else
      {:error, :not_permitted} ->
        conn
        |> assign(:user, user)
        |> put_flash(:error, "You are not allowed to view this challenge's phases")
        |> redirect(to: Routes.challenge_path(conn, :index))

      {:error, :not_found} ->
        conn
        |> assign(:user, user)
        |> put_flash(:error, "Challenge not found")
        |> redirect(to: Routes.challenge_path(conn, :index))

      _ ->
        conn
        |> assign(:user, user)
        |> put_flash(:error, "Something went wrong")
        |> redirect(to: Routes.challenge_path(conn, :index))
    end
  end

  def show(conn, params = %{"challenge_id" => challenge_id, "id" => id}) do
    %{current_user: user} = conn.assigns
    %{page: page, per: _per} = conn.assigns
    per = 10

    filter = Map.get(params, "filter", %{})
    sort = Map.get(params, "sort", %{})

    with {:ok, challenge} <- Challenges.get(challenge_id),
         {:ok, challenge} <- Challenges.allowed_to_edit(user, challenge),
         {:ok, phase} <- Phases.get(id) do
      solutions_filter =
        Map.merge(filter, %{
          "status" => "submitted",
          "phase_id" => phase.id
        })

      %{page: solutions, pagination: pagination} =
        Solutions.all(filter: solutions_filter, page: page, per: per, sort: sort)

      conn
      |> assign(:user, user)
      |> assign(:challenge, challenge)
      |> assign(:phase, phase)
      |> assign(:solutions, solutions)
      |> assign(:pagination, pagination)
      |> assign(:sort, sort)
      |> assign(:filter, filter)
      |> render("show.html")
    else
      {:error, :not_permitted} ->
        conn
        |> assign(:user, user)
        |> put_flash(:error, "You are not allowed to view this phase")
        |> redirect(to: Routes.challenge_path(conn, :index))

      {:error, :not_found} ->
        conn
        |> assign(:user, user)
        |> put_flash(:error, "Phase not found")
        |> redirect(to: Routes.challenge_path(conn, :index))

      _ ->
        conn
        |> assign(:user, user)
        |> put_flash(:error, "Something went wrong")
        |> redirect(to: Routes.challenge_path(conn, :index))
    end
  end
end
