NimbleCSV.define(ChallengeGov.Reports.CSV, separator: ",", escape: "\"")

defmodule Web.Admin.ReportsView do
  use Web, :view

  alias ChallengeGov.Reports.CSV

  def render("security-log-header.csv", _assigns) do
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

  def render("security-log-content.csv", %{record: record}) do
    csv = [
      record.id,
      record.action,
      parse_details(record.details),
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

  defp parse_details(record) do
    if record do
      record
      |> Enum.map(fn x ->
        format_to_readable(x)
      end)
      |> Enum.join(", ")
    end
  end

  defp format_to_readable(x) do
    case elem(x, 0) == "duration" do
      true ->
        ["#{elem(x, 0)}: #{convert_to_iostime(elem(x, 1))}"]

      false ->
        ["#{elem(x, 0)}: #{elem(x, 1)}"]
    end
  end

  defp convert_to_iostime(duration) do
    {hours, minutes, seconds, _microseconds} =
      duration
      |> Timex.Duration.from_seconds()
      |> Timex.Duration.to_clock()

    "#{ensure_double_digits(hours)}:#{ensure_double_digits(minutes)}:#{
      ensure_double_digits(seconds)
    }"
  end

  def ensure_double_digits(elem) do
    result =
      elem
      |> Integer.digits()
      |> length

    case result == 1 do
      true ->
        "0#{elem}"

      false ->
        elem
    end
  end
end
