defmodule Web.Plugs.CheckUserStatus do
  @moduledoc """
  Verify a user is active
  """

  import Plug.Conn
  import Phoenix.Controller

  alias Web.Router.Helpers, as: Routes

  def init(default), do: default

  def call(conn, _opts) do
    with {:ok, user} <- Map.fetch(conn.assigns, :current_user) do
      case user.status do
        "pending" ->
          conn
          |> redirect(to: Routes.admin_terms_path(conn, :pending))
          |> halt()

        "suspended" ->
          conn
          |> clear_flash()
          |> put_flash(:error, "Your account has been suspended")
          |> clear_session()
          |> redirect(to: Routes.session_path(conn, :new))
          |> halt()

        "revoked" ->
          conn
          |> clear_flash()
          |> put_flash(:error, "Your account has been revoked")
          |> clear_session()
          |> redirect(to: Routes.session_path(conn, :new))
          |> halt()

        "deactivated" ->
          conn
          |> clear_flash()
          |> put_flash(:error, "Your account has been deactivated")
          |> clear_session()
          |> redirect(to: Routes.session_path(conn, :new))
          |> halt()

        "decertified" ->
          conn
          |> redirect(to: Routes.admin_access_path(conn, :recertification))
          |> halt()

        "active" ->
          conn

        _ ->
          conn
          |> clear_flash()
          |> put_flash(:error, "Your account has an unknown error")
          |> clear_session()
          |> redirect(to: Routes.session_path(conn, :new))
          |> halt()
      end
    else
      _ ->
        conn
        |> clear_flash()
        |> put_flash(:error, "Your account has an unknown error")
        |> clear_session()
        |> redirect(to: Routes.session_path(conn, :new))
        |> halt()
    end
  end
end
