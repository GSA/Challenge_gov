defmodule Web.Plugs.VerifyAdmin do
  @moduledoc """
  Verify a _admin_ user is in the session
  """

  import Plug.Conn
  import Phoenix.Controller

  alias ChallengeGov.Accounts
  alias Web.Router.Helpers, as: Routes

  def init(default), do: default

  def call(conn, _opts) do
    case is_super_admin?(conn) or is_admin?(conn) do
      true ->
        conn

      false ->
        conn
        |> redirect(to: Routes.dashboard_path(conn, :index))
        |> halt()
    end
  end

  defp is_super_admin?(conn) do
    case Map.fetch(conn.assigns, :current_user) do
      {:ok, user} ->
        Accounts.is_super_admin?(user)

      :error ->
        false
    end
  end

  defp is_admin?(conn) do
    case Map.fetch(conn.assigns, :current_user) do
      {:ok, user} ->
        Accounts.is_admin?(user)

      :error ->
        false
    end
  end
end
