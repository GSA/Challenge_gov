defmodule ChallengeGov.SecurityLogs do
  @moduledoc """
  Context for adding events to security logs
  """
  import Ecto.Query

  alias ChallengeGov.SecurityLogs.SecurityLog
  alias ChallengeGov.Repo
  alias ChallengeGov.Accounts.User
  alias Web.Plugs.SessionTimeout
  alias ChallengeGov.Accounts

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
    # expiration after 180 days
    expiration_date = DateTime.to_unix(Timex.shift(DateTime.utc_now(), days: -180))
    inserted_at = Timex.to_unix(record.inserted_at)

    if expiration_date >= inserted_at do
      Repo.delete(record)
    end
  end

  def log_session_duration(user, session_end) do

    last_accessed_site =
      from(l in SecurityLog,
        where: l.user_id == ^user.id,
        limit: 1,
        order_by: [desc: l.inserted_at]
      )
      |> Repo.one()

    user_accessed_site = Timex.to_unix(last_accessed_site.inserted_at)

    duration = session_end - user_accessed_site

    # TODO: convert to more readable time {ISOtime}?
    track(%SecurityLog{}, user, "session_duration", %{duration: duration})
  end
end
