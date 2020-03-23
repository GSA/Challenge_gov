defmodule ChallengeGov.SecurityLogs do
  @moduledoc """
  Context for adding events to security logs
  """

  alias ChallengeGov.SecurityLogs.SecurityLog
  alias ChallengeGov.Repo

  def track(struct, user, type, data \\ %{}) do
    struct
    |> SecurityLog.changeset(user, type, data)
    |> Repo.insert()
  end

  def all() do
    Repo.all(SecurityLog)
  end

  def check_expired_records() do
    Enum.map(__MODULE__.all(), fn record ->
      remove_expired_records(record)
    end)
  end

  def remove_expired_records(record) do
    inserted_at = Timex.to_unix(record.inserted_at)
    # 180 days ago
    expiration_date = DateTime.to_unix(Timex.shift(DateTime.utc_now(), days: -180))

    if expiration_date >= inserted_at do
      Repo.delete(record)
    end
  end
end
