defmodule Web.PhaseController do
  use Web, :controller

  alias ChallengeGov.Challenges
  alias ChallengeGov.Phases
  alias ChallengeGov.Submissions

  plug Web.Plugs.FetchPage, [per: 10] when action in [:show]

  plug Web.Plugs.EnsureRole, [:super_admin, :admin, :challenge_manager]

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

    selected_submission_ids =
      params
      |> Map.get("sid", [])
      |> Enum.map(&String.to_integer/1)

    with {:ok, challenge} <- Challenges.get(challenge_id),
         {:ok, challenge} <- Challenges.allowed_to_edit(user, challenge),
         {:ok, phase} <- Phases.get(id) do
      submissions_filter =
        Map.merge(filter, %{
          "status" => "submitted",
          "phase_id" => phase.id,
          "managed_accepted" => "true"
        })

      %{page: submissions, pagination: pagination} =
        Submissions.all(filter: submissions_filter, page: page, per: per, sort: sort)

      # REFACTOR: Figure out a better submission here for paginating past the page count
      # after having moved some to a different judging status filter
      %{page: submissions, pagination: pagination} =
        if pagination.total !== 0 and pagination.current > pagination.total do
          Submissions.all(
            filter: submissions_filter,
            page: pagination.total,
            per: per,
            sort: sort
          )
        else
          %{page: submissions, pagination: pagination}
        end

      selected_submission_ids = MapSet.new(selected_submission_ids)
      visible_submission_ids = MapSet.new(Enum.map(submissions, & &1.id))

      checked_selected_submission_ids =
        MapSet.to_list(MapSet.intersection(selected_submission_ids, visible_submission_ids))

      hidden_selected_submission_ids =
        MapSet.to_list(MapSet.difference(selected_submission_ids, visible_submission_ids))

      conn
      |> assign(:user, user)
      |> assign(:challenge, challenge)
      |> assign(:phase, phase)
      |> assign(:submissions, submissions)
      |> assign(:has_closed_phases, Challenges.has_closed_phases?(challenge))
      |> assign(:selected_submission_ids, MapSet.to_list(selected_submission_ids))
      |> assign(:checked_selected_submission_ids, checked_selected_submission_ids)
      |> assign(:hidden_selected_submission_ids, hidden_selected_submission_ids)
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
