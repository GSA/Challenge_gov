defmodule Web.Plugs.CheckUserStatus do
  @moduledoc """
  Verify a user is active
  """

  import Plug.Conn
  import Phoenix.Controller

  alias Web.Router.Helpers, as: Routes

  def init(default), do: default

  def call(conn, _opts) do
    case Map.fetch(conn.assigns, :current_user) do
      {:ok, user} ->
        handle_user_status(conn, user.status)

      _ ->
        conn
        |> clear_flash()
        |> put_flash(:error, "Your account has an unknown error")
        |> clear_session()
        |> redirect(to: Routes.session_path(conn, :new))
        |> halt()
    end
  end

  defp handle_user_status(conn, "pending") do
    conn
    |> redirect(to: Routes.terms_path(conn, :pending))
    |> halt()
  end

  defp handle_user_status(conn, "suspended") do
    conn
    |> clear_flash()
    |> put_flash(:error, "Your account has been suspended")
    |> clear_session()
    |> redirect(to: Routes.session_path(conn, :new))
    |> halt()
  end

  defp handle_user_status(conn, "revoked") do
    conn
    |> clear_flash()
    |> put_flash(:error, "Your account has been revoked")
    |> clear_session()
    |> redirect(to: Routes.session_path(conn, :new))
    |> halt()
  end

  defp handle_user_status(conn, "deactivated") do
    conn
    |> redirect(to: Routes.access_path(conn, :reactivation))
    |> halt()
  end

  defp handle_user_status(conn, "decertified") do
    conn
    |> redirect(to: Routes.access_path(conn, :recertification))
    |> halt()
  end

  defp handle_user_status(conn, "active") do
    conn
  end

  defp handle_user_status(conn, _status) do
    conn
    |> clear_flash()
    |> put_flash(:error, "Your account has an unknown error")
    |> clear_session()
    |> redirect(to: Routes.session_path(conn, :new))
    |> halt()
  end
end
