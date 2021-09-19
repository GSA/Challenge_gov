defmodule Web.Api.SubmissionController do
  use Web, :controller

  alias ChallengeGov.Challenges
  alias ChallengeGov.Phases
  alias ChallengeGov.Submissions

  plug(
    Web.Plugs.EnsureRole,
    [:admin, :super_admin, :challenge_manager] when action in [:update_judging_status]
  )

  def update_judging_status(conn, params = %{"id" => id, "judging_status" => judging_status}) do
    %{current_user: user} = conn.assigns

    filter = Map.get(params, "filter", %{})

    with {:ok, submission} <- Submissions.get(id),
         {:ok, challenge} <- Challenges.get(submission.challenge_id),
         {:ok, phase} <- Phases.get(submission.phase_id),
         {:ok, _challenge} <- Challenges.allowed_to_edit(user, challenge),
         {:ok, updated_submission} <-
           Submissions.update_judging_status(submission, judging_status) do
      conn
      |> assign(:challenge, challenge)
      |> assign(:phase, phase)
      |> assign(:submission, submission)
      |> assign(:updated_submission, updated_submission)
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
