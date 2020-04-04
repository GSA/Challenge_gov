defmodule ChallengeGov.SecurityLogs do
  @moduledoc """
  Context for adding events to security logs
  """
  import Ecto.Query

  alias ChallengeGov.SecurityLogs.SecurityLog
  alias ChallengeGov.Repo

  def track(struct, params) do
    struct
    |> SecurityLog.changeset(params)
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
    inserted_at = Timex.to_unix(record.logged_at)

    if expiration_date >= inserted_at do
      Repo.delete(record)
    end
  end

  def log_session_duration(user, session_end) do
    last_accessed_site =
      SecurityLog
      |> where([l], l.target_id == ^user.id)
      |> limit(1)
      |> order_by([l], desc: l.logged_at)
      |> Repo.one()

    if last_accessed_site do
      user_accessed_site = Timex.to_unix(last_accessed_site.logged_at)

      duration = session_end - user_accessed_site

      # TODO: convert to more readable time {ISOtime}?
      track(%SecurityLog{}, %{
        action: "session_duration",
        details: %{duration: duration},
        target_id: user.id,
        target_type: user.role,
        target_identifier: user.email
      })
    end
  end
end
