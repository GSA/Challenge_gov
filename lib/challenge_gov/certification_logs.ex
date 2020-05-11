defmodule ChallengeGov.CertificationLogs do
  @moduledoc """
  Context for adding events to certification log
  """

  import Ecto.Query
  require Logger
  alias ChallengeGov.Accounts
  alias ChallenegGov.CertificationLogs.CertificationLog
  alias ChallengeGov.Repo
  alias ChallengeGov.Security

  def track(params) do
    %CertificationLog{}
    |> CertificationLog.changeset(params)
    |> Repo.insert()
  end

  def check_user_certifications do
    two_days_ago = Timex.shift(Timex.now(), days: -2)

    # get records where user is not decertified and expiry is past now
    results =
      CertificationLog
      |> join(:left, [r], user in assoc(r, :user))
      |> where([r, user], r.user_id == user.id and user.status != "decertified")
      |> where([r], is_nil(r.decertified_at))
      |> where([r], r.expires_at < ^Timex.now() and r.updated_at > ^two_days_ago)
      |> Repo.all()

    # decertify found users
    Enum.map(results, fn r ->
      with {:ok, user} <- Accounts.get(r.user_id) do
        Accounts.decertify(user)
      end
    end)
  end

  @doc """
  Get most current certification record by user id
  """
  def get_current_certification(user_id) do
    result =
      CertificationLog
      |> where([r], r.user_id == ^user_id)
      |> limit(1)
      |> order_by([r], desc: r.expires_at)
      |> Repo.all()
      |> List.first()

    case result do
      nil ->
        {:error, :no_log_found}

      result ->
        {:ok, result}
    end
  end

  @doc """
  calculate certification expiry based on decertification env var
  """
  def calulate_expiry() do
    decertification_interval = Security.decertify_days()
    expiry = Timex.shift(DateTime.utc_now(), days: decertification_interval)
    DateTime.truncate(expiry, :second)
  end

  @doc """
  Stream certification log for CSV download
  """
  def stream_all_records() do
    CertificationLog
    |> order_by([r], asc: r.id)
    |> Repo.all()
  end

  @doc """
  Filter security log for CSV download
  """
  def filter_by_params(params) do
    %{"year" => year} = params

    {datetime_start, datetime_end} = range_from(String.to_integer(year))

    CertificationLog
    |> where([r], r.certified_at >= ^datetime_start)
    |> where([r], r.certified_at <= ^datetime_end)
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
