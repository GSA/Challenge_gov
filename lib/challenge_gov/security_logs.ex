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
end
