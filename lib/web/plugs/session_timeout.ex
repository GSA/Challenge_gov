defmodule Web.Plugs.SessionTimeout do
  @moduledoc """
  Manage session timeout
  """
  alias Web.SessionController
  alias ChallengeGov.Accounts
  alias ChallengeGov.Security

  def init(opts \\ []) do
    Keyword.merge([timeout_after_minutes: Security.timeout_interval()], opts)
  end

  def call(conn, opts) do
    %{current_user: user} = conn.assigns
    Accounts.update_last_active(user)
    SessionController.check_session_timeout(conn, opts)
  end
end
