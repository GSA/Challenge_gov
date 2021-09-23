defmodule Web.SubmissionExportController do
  use Web, :controller

  alias ChallengeGov.Challenges
  alias ChallengeGov.Phases
  alias ChallengeGov.SubmissionExports

  plug(Web.Plugs.EnsureRole, [:super_admin, :admin, :challenge_manager])

  def index(conn, %{"id" => id}) do
    %{current_user: user} = conn.assigns

    with {:ok, challenge} <- Challenges.get(id),
         {:ok, challenge} <- Challenges.allowed_to_edit(user, challenge),
         true <- Challenges.has_closed_phases?(challenge) do
      submission_exports = SubmissionExports.all(challenge)
      closed_phases = Phases.closed_for_challenge(challenge)

      conn
      |> assign(:user, user)
      |> assign(:challenge, challenge)
      |> assign(:closed_phases, closed_phases)
      |> assign(:submission_exports, submission_exports)
      |> render("index.html")
    else
      {:error, :not_found} ->
        conn
        |> put_flash(:error, "Challenge not found")
        |> redirect(to: Routes.dashboard_path(conn, :index))

      {:error, :not_permitted} ->
        conn
        |> put_flash(:error, "You are not authorized to export this challenge's submissions")
        |> redirect(to: Routes.dashboard_path(conn, :index))

      # Case where there are no closed phases
      false ->
        conn
        |> put_flash(:error, "Challenge has no closed phases to export")
        |> redirect(to: Routes.dashboard_path(conn, :index))
    end
  end

  def create(conn, params = %{"id" => id}) do
    %{current_user: user} = conn.assigns

    {:ok, challenge} = Challenges.get(id)

    with {:ok, challenge} <- Challenges.allowed_to_edit(user, challenge),
         {:ok, submission_export} <- SubmissionExports.create(params, challenge),
         {:ok, _submission_export_job} <- SubmissionExports.trigger_export(submission_export) do
      conn
      |> put_flash(:info, "Submission export created")
      |> redirect(to: Routes.submission_export_path(conn, :index, challenge.id))
    else
      {:error, :invalid_format} ->
        conn
        |> put_flash(:error, "Invalid export format")
        |> redirect(to: Routes.dashboard_path(conn, :index))

      {:error, :not_permitted} ->
        conn
        |> put_flash(:error, "You are not authorized to export this challenge")
        |> redirect(to: Routes.dashboard_path(conn, :index))

      {:error, %{errors: [phase_ids: {error_msg, _}]}} ->
        conn
        |> put_flash(:error, error_msg)
        |> redirect(to: Routes.submission_export_path(conn, :index, challenge.id))

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Please select all export options")
        |> redirect(to: Routes.submission_export_path(conn, :index, challenge.id))

      _ ->
        conn
        |> put_flash(:error, "Something went wrong")
        |> redirect(to: Routes.dashboard_path(conn, :index))
    end
  end

  def restart(conn, %{"id" => id}) do
    %{current_user: user} = conn.assigns

    with {:ok, submission_export} <- SubmissionExports.get(id),
         {:ok, challenge} <- Challenges.get(submission_export.challenge_id),
         {:ok, _challenge} <- Challenges.allowed_to_edit(user, challenge),
         {:ok, _submission_export_job} <- SubmissionExports.restart_export(submission_export) do
      conn
      |> put_flash(:info, "Submission export restarted")
      |> redirect(to: Routes.submission_export_path(conn, :index, submission_export.challenge_id))
    else
      _ ->
        conn
        |> put_flash(:error, "Something went wrong")
        |> redirect(to: Routes.dashboard_path(conn, :index))
    end
  end

  def delete(conn, %{"id" => id}) do
    %{current_user: user} = conn.assigns

    with {:ok, submission_export} <- SubmissionExports.get(id),
         {:ok, challenge} <- Challenges.get(submission_export.challenge_id),
         {:ok, _challenge} <- Challenges.allowed_to_edit(user, challenge),
         {:ok, submission_export} <- SubmissionExports.delete(submission_export) do
      conn
      |> put_flash(:info, "Submission export cancelled")
      |> redirect(to: Routes.submission_export_path(conn, :index, submission_export.challenge_id))
    else
      _ ->
        conn
        |> put_flash(:error, "Something went wrong")
        |> redirect(to: Routes.dashboard_path(conn, :index))
    end
  end
end
