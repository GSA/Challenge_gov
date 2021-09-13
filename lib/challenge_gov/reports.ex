defmodule ChallengeGov.Reports do
  @moduledoc """
  Context for creating a report
  """

  import Ecto.Query
  import Ecto.Changeset
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
        range_from(
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

  defp range_from(year, month, day) do
    case {year, month, day} do
      {year, month, day} when month == nil and day == nil ->
        # just year given
        datetime_start =
          year
          |> Timex.beginning_of_year()
          |> Timex.to_datetime()

        datetime_end =
          year
          |> Timex.end_of_year()
          |> Timex.to_datetime()
          |> Timex.end_of_day()
          |> Timex.to_datetime()

        {datetime_start, datetime_end}

      {year, month, day} when day == nil ->
        # month/year given
        datetime_start =
          year
          |> Timex.beginning_of_month(month)
          |> Timex.to_datetime()
          |> Timex.beginning_of_day()

        datetime_end =
          year
          |> Timex.end_of_month(month)
          |> Timex.to_datetime()
          |> Timex.end_of_day()

        {datetime_start, datetime_end}

      {year, month, day} ->
        # day/month/year given
        datetime_start =
          {year, month, day}
          |> Timex.to_datetime()
          |> Timex.beginning_of_day()

        datetime_end =
          {year, month, day}
          |> Timex.to_datetime()
          |> Timex.end_of_day()

        {datetime_start, datetime_end}
    end
  end

  def generate_date_options do
    months =
      Enum.reduce(1..12, [], fn num, acc ->
        Enum.concat(acc, [{Timex.month_name(num), num}])
      end)

    days = Range.new(1, 31)
    years = Range.new(Timex.now().year, 2020)

    [years, months, days]
  end
end
