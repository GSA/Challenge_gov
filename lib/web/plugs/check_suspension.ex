defmodule Web.Plugs.CheckSuspension do
  @moduledoc """
  Verify a user is not suspended
  """

  import Plug.Conn
  import Phoenix.Controller

  alias Web.Router.Helpers, as: Routes

  def init(default), do: default

  def call(conn, _opts) do
    case is_suspended?(conn) do
      true ->
        conn
        |> put_flash(:error, "Your account has been suspended")
        |> clear_session()
        |> redirect(to: Routes.session_path(conn, :new))
        |> halt()

      _ ->
        conn
    end
  end

  defp is_suspended?(conn) do
    case Map.fetch(conn.assigns, :current_user) do
      {:ok, user} ->
        user.suspended

      :error ->
        true
    end
  end
end
