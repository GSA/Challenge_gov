defmodule ChallengeGov.Reports do
  @moduledoc """
  Context for creating a report
  """

  import Ecto.Query

  alias ChallengeGov.Repo

  alias ChallengeGov.SecurityLogs.SecurityLog

  # @doc """
  # Stream security log records for CSV download
  # """
  def stream_all_records() do
    SecurityLog
    |> order_by([r], asc: r.id)
    |> Repo.all()
  end
end
