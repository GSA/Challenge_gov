defmodule Web.Plugs.SessionTimeout do
  @moduledoc """
  Manage session timeout
  """
  alias Web.SessionController

  def init(opts \\ []) do
    Keyword.merge([timeout_after_minutes: timeout_interval()], opts)
  end

  def call(conn, opts) do
    SessionController.check_session_timeout(conn, opts)
  end

  defp timeout_interval do
    {timeout, _} = Integer.parse(Application.get_env(:challenge_gov, :session_timeout_in_minutes))
    timeout
  end
end
