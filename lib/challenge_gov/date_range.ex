defmodule ChallengeGov.DateRange do
  @moduledoc """
  Date range.
  """

  def range_from(year, month, day) do
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
end
