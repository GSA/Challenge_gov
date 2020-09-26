NimbleCSV.define(ChallengeGov.Export.CSV, separator: ",", escape: "\"")

defmodule Web.ExportView do
  use Web, :view

  alias ChallengeGov.Export.CSV
  alias Web.Api.ChallengeView

  def challenge_csv(challenge) do
    CSV.dump_to_iodata([csv_headers(), csv_content(challenge)])
  end

  def challenge_json(challenge) do
    {:ok, json} =
      challenge
      |> ChallengeView.to_json()
      |> Jason.encode()

    json
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
end
