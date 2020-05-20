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

  def check_for_expired_certifications do
    two_days_ago = Timex.shift(Timex.now(), days: -2)

    # get records where user is not decertified and expiry is past now
    results =
      CertificationLog
      |> join(:left, [r], user in assoc(r, :user))
      |> where(
        [r, user],
        r.user_id == user.id and
          user.status != "decertified" and
          user.status != "suspended" and
          user.status != "revoked" and
          user.role != "solver"
      )
      |> where([r], is_nil(r.requested_at))
      |> where([r], r.updated_at > ^two_days_ago)
      |> order_by([r], desc: r.updated_at)
      |> Repo.all()

    # filter to most recent result per user
    unique_results_by_user = Enum.uniq_by(results, fn x -> x.user_id end)

    # decertify found users
    Enum.map(unique_results_by_user, fn r ->
      if Timex.to_unix(r.expires_at) < Timex.to_unix(Timex.now()) do
        with {:ok, user} <- Accounts.get(r.user_id) do
          Accounts.decertify(user)
        end
      end
    end)
  end

  @doc """
  Get most current certification record by user id
  """
  def get_current_certification(user) do
    case user.role == "solver" do
      true ->
        {:ok, %{}}

      false ->
        result =
          CertificationLog
          |> where([r], r.user_id == ^user.id)
          |> where([r], is_nil(r.requested_at))
          |> order_by([r], desc: r.expires_at)
          |> limit(1)
          |> Repo.all()
          |> List.first()

        case result do
          nil ->
            {:error, :no_log_found}

          result ->
            {:ok, result}
        end
    end
  end

  def check_user_certification_history(user) do
    case user.role == "solver" do
      true ->
        {:ok, %{}}

      false ->
        result =
          CertificationLog
          |> where([r], r.user_id == ^user.id)
          |> order_by([r], desc: r.expires_at)
          |> limit(1)
          |> Repo.all()
          |> List.first()

        case result do
          nil ->
            {:error, :no_log_found}

          result ->
            {:ok, result}
        end
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
