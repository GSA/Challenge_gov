defmodule Web.Plugs.SessionTimeout do
  @moduledoc """
  Manage session timeout
  """
  import Plug.Conn
  alias Web.SessionController

  def init(opts \\ []) do
    Keyword.merge([timeout_after_minutes: timeout_interval()], opts)
  end

  def call(conn, opts) do
    SessionController.check_session_timeout(conn, opts)
  end

  defp timeout_interval do
    Application.get_env(:challenge_gov, :session_timeout_in_minutes)
  end

end
