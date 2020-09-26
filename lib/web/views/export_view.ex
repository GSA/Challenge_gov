NimbleCSV.define(ChallengeGov.Export.CSV, separator: ",", escape: "\"")

defmodule Web.ExportView do
  use Web, :view

  alias ChallengeGov.Export.CSV
  alias Web.Api.ChallengeView

  def format_content(challenge, format) do
    case format do
      "json" ->
        {:ok, challenge_json(challenge)}

      "csv" ->
        {:ok, challenge_csv(challenge)}

      _ ->
        {:error, :invalid_format}
    end
  end

  def challenge_csv(challenge) do
    CSV.dump_to_iodata([csv_headers(), csv_content(challenge)])
  end

  defp csv_headers do
    [
      "ID",
      "UUID",
      "Title",
      "Agency",
      "Status"
    ]
  end

  defp csv_content(challenge) do
    [
      challenge.id,
      challenge.uuid,
      challenge.title,
      challenge.agency.name,
      Web.ChallengeView.status_display_name(challenge)
    ]
  end

  def challenge_json(challenge) do
    {:ok, json} =
      challenge
      |> ChallengeView.to_json()
      |> Jason.encode()

    json
  end
end
