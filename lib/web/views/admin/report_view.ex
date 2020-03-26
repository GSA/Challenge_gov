NimbleCSV.define(ChallengeGov.Reports.CSV, separator: ",", escape: "\"")

defmodule ChallengeGov.Admin.ReportView do
  use Web, :view

  alias ChallengeGov.Reports.CSV

  def render("security-logs-header.csv", _assigns) do
    headers = [
      "Record ID",
      "User ID",
      "Type",
      "Details",
      "Inserted At",
      "Updated At"
    ]

    CSV.dump_to_iodata([headers])
  end

  def render("security-logs-content.csv", %{record: record}) do
    csv = [
      record.id,
      record.user_id,
      record.type,
      format_to_readable(record.data),
      record.inserted_at,
      record.updated_at
    ]

    CSV.dump_to_iodata([csv])
  end

  defp format_to_readable(record) do
    record
    |> Enum.map(fn x ->
      ["#{elem(x, 0)}: #{elem(x, 1)}"]
    end)
  end
end
