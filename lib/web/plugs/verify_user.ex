defmodule Web.Plugs.VerifyUser do
  @moduledoc """
  Verify a _admin_ user is in the session
  """

  import Plug.Conn
  import Phoenix.Controller

  alias Web.Router.Helpers, as: Routes

  def init(default), do: default

  def call(conn, _opts) do
    case Map.has_key?(conn.assigns, :current_user) do
      true ->
        conn

      false ->
        conn
        |> redirect(to: Routes.session_path(conn, :new))
        |> halt()
    end
  end
end
