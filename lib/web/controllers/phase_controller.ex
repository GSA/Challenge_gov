defmodule Web.PhaseController do
  use Web, :controller

  alias ChallengeGov.Challenges
  alias ChallengeGov.Phases
  alias ChallengeGov.Challenges.Phase
  alias ChallengeGov.Solutions

  plug Web.Plugs.FetchPage, [per: 10] when action in [:show]

  plug Web.Plugs.EnsureRole, [:super_admin, :admin, :challenge_owner]

  def index(conn, %{"challenge_id" => challenge_id}) do
    %{current_user: user} = conn.assigns

    with {:ok, challenge} <- Challenges.get(challenge_id),
         {:ok, challenge} <- Challenges.allowed_to_edit(user, challenge) do
      conn
      |> assign(:user, user)
      |> assign(:challenge, challenge)
      |> assign(:phases, challenge.phases)
      |> assign(:has_closed_phases, Challenges.has_closed_phases?(challenge))
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
    %{current_user: user, page: page, per: per} = conn.assigns

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

      # REFACTOR: Figure out a better solution here for paginating past the page count
      # after having moved some to a different judging status filter
      %{page: solutions, pagination: pagination} =
        if pagination.total !== 0 and pagination.current > pagination.total do
          Solutions.all(filter: solutions_filter, page: pagination.total, per: per, sort: sort)
        else
          %{page: solutions, pagination: pagination}
        end

      conn
      |> assign(:user, user)
      |> assign(:challenge, challenge)
      |> assign(:phase, phase)
      |> assign(:solutions, solutions)
      |> assign(:has_closed_phases, Challenges.has_closed_phases?(challenge))
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

  def create_winners(conn, %{"challenge_id" => cid, "phase_id" => pid} = params) do
    challenge = Challenges.get(cid)

    conn
    |> assign(:challenge, challenge)
  end   

  def winners(conn, %{"challenge_id" => cid, "phase_id" => phid} = params) do
    {:ok, challenge} = Challenges.get(cid)
    {:ok, phase} = Phases.get(phid)
    changeset = Phase.changeset(phase, %{})
    
    conn
    |> assign(:changeset, changeset)    
    |> assign(:challenge_id, cid)
    |> assign(:phase_id, phid)
    |> assign(:challenge, challenge)
    |> assign(:phase, phase)
    |> render("winners.html")
  end

  def winners_published(conn, %{"challenge_id" => cid, "phase_id" => pid} = params) do
    {:ok, phase} = Phases.get(pid)
    IO.inspect("PHASE THEN CHANGESET")
    changeset = Phase.changeset(phase, %{}) |> IO.inspect

    conn
    |> Phoenix.Controller.put_layout(false)
    |> assign(:changeset, changeset)
    |> render("winners_published.html")
  end
end
