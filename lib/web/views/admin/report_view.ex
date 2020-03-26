NimbleCSV.define(ChallengeGov.Reports.CSV, separator: ",", escape: "\"")

defmodule ChallengeGov.Admin.ReportView do
  use Web, :view

  alias ChallengeGov.Reports.CSV

  def render("security-logs.csv", _assigns) do
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
      record.data,
      record.inserted_at,
      record.updated_at
    ]

    CSV.dump_to_iodata([csv])
  end
end
