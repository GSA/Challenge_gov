defmodule ChallengeGov.Reports do
  @moduledoc """
  Context for creating a report
  """

  import Ecto.Query

  alias ChallengeGov.Repo

  alias ChallengeGov.SecurityLogs.SecurityLog

  # @doc """
  # Stream security log records for CSV download
  # """
  def stream_all_records() do
    SecurityLog
    |> order_by([r], asc: r.id)
    |> Repo.all()
  end

  def filter_by_params(params) do
    %{"year" => year, "month" => month, "day" => day} = params
    {datetime_start, datetime_end} = range_from(year, month, day)

    SecurityLog
    |> where([r], r.logged_at >= ^datetime_start)
    |> where([r], r.logged_at <= ^datetime_end)
    |> order_by([r], asc: r.id)
    |> Repo.all()
  end

  defp range_from(year, month, day) do
    case {year, month, day} do
      {year, month, day} when month == "" and day == "" ->
        # just year given
        datetime_start =
          String.to_integer(year)
          |> Timex.beginning_of_year()
          |> Timex.to_datetime()

        datetime_end =
          String.to_integer(year)
          |> Timex.end_of_year()
          |> Timex.to_datetime()
          |> Timex.end_of_day()
          |> Timex.to_datetime()

        {datetime_start, datetime_end}

      {year, month, day} when day == "" ->
        # month/year given
        datetime_start =
          String.to_integer(year)
          |> Timex.beginning_of_month(String.to_integer(month))
          |> Timex.to_datetime()
          |> Timex.beginning_of_day()

        datetime_end =
          String.to_integer(year)
          |> Timex.end_of_month(String.to_integer(month))
          |> Timex.to_datetime()
          |> Timex.end_of_day()

        {datetime_start, datetime_end}

      {year, month, day} ->
        # day/month/year given
        datetime_start =
          {String.to_integer(year), String.to_integer(month), String.to_integer(day)}
          |> Timex.to_datetime()
          |> Timex.beginning_of_day()

        datetime_end =
          {String.to_integer(year), String.to_integer(month), String.to_integer(day)}
          |> Timex.to_datetime()
          |> Timex.end_of_day()

        {datetime_start, datetime_end}
    end
  end
end
