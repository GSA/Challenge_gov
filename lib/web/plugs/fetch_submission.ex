defmodule Web.Plugs.FetchSubmission do
  @moduledoc """
  Fetches a submission and assigns it to the conn.
  """
  import Plug.Conn

  alias ChallengeGov.Submissions

  def init(default), do: default

  def call(conn, _opts) do
    case Submissions.get(conn.params["id"]) do
      {:ok, submission} ->
        assign(conn, :current_submission, submission)

      {:error, :not_found} ->
        conn
    end
  end
end
