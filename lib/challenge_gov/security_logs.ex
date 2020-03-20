defmodule ChallengeGov.SecurityLogs do
  @moduledoc """
  Context for adding events to security logs
  """

  alias ChallengeGov.SecurityLogs.SecurityLog
  
  def track(user, type, data \\ %{}) do
    user
    |> SecurityLog.changeset(type, data)
    |> Repo.insert()
  end

end
