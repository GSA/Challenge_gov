NimbleCSV.define(ChallengeGov.Reports.CSV, separator: ",", escape: "\"")

defmodule ChallengeGov.Admin.ReportView do
  use Web, :view

  alias ChallengeGov.Reports.CSV

  def render("security-logs-header.csv", _assigns) do
    headers = [
      "ID",
      "Action",
      "Details",
      "Originator ID",
      "Originator Type",
      "Originator Identifier",
      "Target ID",
      "Target Type",
      "Target Identifier",
      "Logged At"
    ]

    CSV.dump_to_iodata([headers])
  end

  def render("security-logs-content.csv", %{record: record}) do
    csv = [
      record.id,
      record.action,
      format_to_readable(record.details),
      record.originator_id,
      record.originator_role,
      record.originator_identifier,
      record.target_id,
      record.target_type,
      record.target_identifier,
      record.logged_at
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
