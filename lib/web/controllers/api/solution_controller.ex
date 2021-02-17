defmodule Web.Api.SolutionController do
  use Web, :controller

  alias ChallengeGov.Challenges
  alias ChallengeGov.Phases
  alias ChallengeGov.Solutions
  alias Web.Api.ErrorView

  plug(
    Web.Plugs.EnsureRole,
    [:admin, :super_admin, :challenge_owner] when action in [:update_judging_status]
  )

  def update_judging_status(conn, params = %{"id" => id, "judging_status" => judging_status}) do
    %{current_user: user} = conn.assigns

    filter = Map.get(params, "filter", %{})

    with {:ok, solution} <- Solutions.get(id),
         {:ok, challenge} <- Challenges.get(solution.challenge_id),
         {:ok, phase} <- Phases.get(solution.phase_id),
         {:ok, _challenge} <- Challenges.allowed_to_edit(user, challenge),
         {:ok, updated_solution} <- Solutions.update_judging_status(solution, judging_status) do
      conn
      |> Phoenix.Controller.put_layout(false)
      |> assign(:challenge, challenge)
      |> assign(:phase, phase)
      |> assign(:solution, solution)
      |> assign(:updated_solution, updated_solution)
      |> assign(:filter, filter)
      |> render("judging_status.json")
    else
      {:error, :not_permitted} ->
        send_resp(conn, 403, "")

      _ ->
        send_resp(conn, 400, "")
    end
  end
end
