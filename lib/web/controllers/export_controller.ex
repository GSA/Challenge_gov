defmodule Web.ExportController do
  use Web, :controller

  alias ChallengeGov.Challenges
  alias Web.ExportView

  plug(Web.Plugs.EnsureRole, [:super_admin, :admin, :challenge_manager])

  def export_challenge(conn, %{"id" => id, "format" => format}) do
    %{current_user: user} = conn.assigns

    with {:ok, challenge} <- Challenges.get(id),
         {:ok, challenge} <- Challenges.allowed_to_edit(user, challenge),
         {:ok, content} <- ExportView.format_content(challenge, format) do
      send_download(conn, {:binary, content}, filename: "#{id}.#{format}")
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
