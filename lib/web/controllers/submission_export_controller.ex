defmodule Web.SubmissionExportController do
  use Web, :controller

  alias ChallengeGov.Challenges
  alias ChallengeGov.Solutions
  alias Web.SubmissionExportView

  plug(Web.Plugs.EnsureRole, [:super_admin, :admin, :challenge_owner])

  def index(conn, %{"id" => id}) do
    %{current_user: user} = conn.assigns

    with {:ok, challenge} <- Challenges.get(id),
         {:ok, challenge} <- Challenges.allowed_to_edit(user, challenge) do
      conn
      |> assign(:user, user)
      |> assign(:challenge, challenge)
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
    end
  end

  def create(conn, %{
        "id" => id,
        "phases" => phase_ids,
        "judging_status" => judging_status,
        "format" => format
      }) do
    %{current_user: user} = conn.assigns

    with {:ok, challenge} <- Challenges.get(id),
         {:ok, challenge} <- Challenges.allowed_to_edit(user, challenge),
         submissions <-
           Solutions.all(filter: %{"phase_ids" => phase_ids, "judging_status" => judging_status}),
         {:ok, content} <- SubmissionExportView.format_content(submissions, format) do
      if length(submissions) > 0 do
        send_download(conn, {:binary, content}, filename: "submissions.csv")
      else
        conn
        |> put_flash(:error, "No submissions for those selections")
        |> redirect(to: Routes.submission_export_path(conn, :index, challenge.id))
      end
    else
      {:error, :invalid_format} ->
        conn
        |> put_flash(:error, "Invalid export format")
        |> redirect(to: Routes.dashboard_path(conn, :index))

      {:error, :not_found} ->
        conn
        |> put_flash(:error, "Challenge not found")
        |> redirect(to: Routes.dashboard_path(conn, :index))

      {:error, :not_permitted} ->
        conn
        |> put_flash(:error, "You are not authorized to export this challenge")
        |> redirect(to: Routes.dashboard_path(conn, :index))

      _ ->
        conn
        |> put_flash(:error, "Something went wrong")
        |> redirect(to: Routes.dashboard_path(conn, :index))
    end
  end
end
