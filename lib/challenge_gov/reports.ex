defmodule ChallengeGov.Reports do
  @moduledoc """
  Context for creating a report
  """

  import Ecto.Query
  import Ecto.Changeset
  
  alias ChallengeGov.DateRange
  alias ChallengeGov.Repo
  alias ChallengeGov.Reports.Report
  alias ChallengeGov.SecurityLogs.SecurityLog

  # @doc """
  # Stream security log records for CSV download
  # """
  def stream_all_records() do
    records =
      SecurityLog
      |> order_by([r], asc: r.id)
      |> Repo.all()

    {:ok, records}
  end

  def filter_by_params(params) do
    %{"report" => %{"year" => year, "month" => month, "day" => day}} = params

    changeset =
      Report.changeset(%Report{}, %{
        "year" => sanitize_param(year),
        "month" => sanitize_param(month),
        "day" => sanitize_param(day)
      })

    if changeset.valid? do
      {datetime_start, datetime_end} =
        DateRange.range_from(
          sanitize_param(year),
          sanitize_param(month),
          sanitize_param(day)
        )

      records =
        SecurityLog
        |> where([r], r.logged_at >= ^datetime_start)
        |> where([r], r.logged_at <= ^datetime_end)
        |> order_by([r], asc: r.id)
        |> Repo.all()

      {:ok, records}
    else
      changeset = apply_action(changeset, :update)
      changeset
    end
  end

  defp sanitize_param(value) do
    if value == "", do: nil, else: String.to_integer(value)
  end
end
