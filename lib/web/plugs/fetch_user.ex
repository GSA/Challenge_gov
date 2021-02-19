defmodule Web.Plugs.FetchUser do
  @moduledoc """
  Fetch a user from the session
  """
  @behaviour Plug

  import Plug.Conn

  alias ChallengeGov.Accounts

  @impl Plug
  def init(default), do: default

  @impl Plug
  def call(conn, _opts) do
    case conn |> get_session(:user_token) do
      nil ->
        conn

      token ->
        load_user(conn, Accounts.get_by_token(token))
    end
  end

  defp load_user(conn, {:ok, user}) do
    assign(conn, :current_user, user)
  end

  defp load_user(conn, _), do: conn
end
