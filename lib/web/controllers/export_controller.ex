defmodule Web.ExportController do
  use Web, :controller

  alias ChallengeGov.Challenges
  alias Web.ExportView

  plug(Web.Plugs.EnsureRole, [:super_admin, :admin, :challenge_owner])

  def export_challenge(conn, %{"id" => id, "format" => format}) do
    {:ok, challenge} = Challenges.get(id)

    content =
      case format do
        "json" ->
          ExportView.challenge_json(challenge)

        "csv" ->
          ExportView.challenge_csv(challenge)

        _ ->
          "Invalid format"
      end

    send_download(conn, {:binary, content}, filename: "#{id}.#{format}")
  end
end
