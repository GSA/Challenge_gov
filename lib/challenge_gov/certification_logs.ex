defmodule ChallengeGov.CertificationLogs do
  @moduledoc """
  Context for adding events to certification log
  """

  import Ecto.Query
  require Logger
  alias ChallenegGov.CertificationLogs.CertificationLog
  alias ChallengeGov.Repo
  alias ChallengeGov.Security

  def track(params) do
    %CertificationLog{}
    |> CertificationLog.changeset(params)
    |> Repo.insert()
  end

  # def check_user_certifications() do
  #   Repo.all(CertificationLog)
  # end

  def calulate_expiry() do
    decertification_interval = Security.decertify_days()
    expiry = Timex.shift(DateTime.utc_now(), days: decertification_interval)
    DateTime.truncate(expiry, :second)
  end

  # @doc """
  # Stream certification log for CSV download
  # """
  def stream_all_records() do
    CertificationLog
    |> order_by([r], asc: r.id)
    |> Repo.all()
  end

  # @doc """
  # Filter security log for CSV download
  # """
  def filter_by_params(params) do
    %{"year" => year} = params

    {datetime_start, datetime_end} = range_from(year)

    CertificationLog
    |> where([r], r.inserted_at >= ^datetime_start)
    |> where([r], r.inserted_at <= ^datetime_end)
    |> order_by([r], asc: r.id)
    |> Repo.all()
  end

  defp range_from(year) do
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
  end
end
