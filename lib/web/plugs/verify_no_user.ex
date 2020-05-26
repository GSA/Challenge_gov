defmodule Web.Plugs.VerifyNoUser do
  @moduledoc """
  Verify a _admin_ user is in the session
  """

  import Plug.Conn
  import Phoenix.Controller

  alias Web.Router.Helpers, as: Routes

  def init(default), do: default

  def call(conn, _opts) do
    case Map.has_key?(conn.assigns, :current_user) do
      false ->
        conn

      true ->
        conn
        |> put_flash(:info, "You are already signed in.")
        |> redirect(to: Routes.dashboard_path(conn, :index))
        |> halt()
    end
  end
end
