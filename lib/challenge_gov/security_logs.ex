defmodule ChallengeGov.SecurityLogs do
  @moduledoc """
  Context for adding events to security logs
  """
  import Ecto.Query

  alias ChallengeGov.Accounts
  alias ChallengeGov.Accounts.User
  alias ChallengeGov.Repo
  alias ChallengeGov.Security
  alias ChallengeGov.SecurityLogs.SecurityLog

  def track(struct, params) do
    struct
    |> SecurityLog.changeset(params)
    |> Repo.insert()
  end

  def all() do
    Repo.all(SecurityLog)
  end

  def check_expired_records() do
    # TODO just use a database query to delete old records
    Enum.map(__MODULE__.all(), fn record ->
      remove_expired_records(record)
    end)
  end

  def remove_expired_records(record) do
    expiration_date =
      DateTime.to_unix(Timex.shift(DateTime.utc_now(), days: -1 * Security.log_retention_days()))

    inserted_at = Timex.to_unix(record.logged_at)

    if expiration_date >= inserted_at do
      Repo.delete(record)
    end
  end

  def log_session_duration(user, session_end) do
    last_accessed_site =
      SecurityLog
      |> where([l], l.originator_id == ^user.id and l.action == "accessed_site")
      |> limit(1)
      |> order_by([l], desc: l.logged_at)
      |> Repo.one()

    if last_accessed_site do
      user_accessed_site = Timex.to_unix(last_accessed_site.logged_at)
      duration = session_end - user_accessed_site

      Accounts.update_active_session(user, false)

      track(%SecurityLog{}, %{
        action: "session_duration",
        details: %{duration: duration},
        originator_id: user.id,
        originator_role: user.role,
        originator_identifier: user.email
      })
    end
  end

  def check_for_timed_out_sessions do
    active_users =
      User
      |> where([u], u.active_session == true)
      |> Repo.all()

    timeout_interval_in_minutes = Security.timeout_interval()

    if !is_nil(active_users) do
      Enum.map(active_users, fn x ->
        session_timeout = Timex.to_unix(x.last_active) + timeout_interval_in_minutes * 60
        maybe_update_timed_out_sessions(x, session_timeout)
      end)
    end
  end

  def maybe_update_timed_out_sessions(user, session_timeout) do
    # 5 min buffer after session should have timed out to avoid overlap
    if Timex.to_unix(Timex.now()) >= session_timeout + 300 do
      log_session_duration(user, session_timeout)
    end
  end
end
