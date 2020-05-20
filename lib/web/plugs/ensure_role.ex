defmodule Web.Plugs.EnsureRole do
  @moduledoc """
  Verify a user's role
  """

  import Plug.Conn
  import Phoenix.Controller

  alias Web.Router.Helpers, as: Routes

  def init(default), do: default

  def call(conn, roles) do
    conn.assigns
    |> Map.fetch(:current_user)
    |> has_role?(roles)
    |> maybe_halt(conn)
  end

  defp has_role?(:error, _roles), do: false

  defp has_role?({:ok, user}, roles) when is_list(roles),
    do: Enum.any?(roles, &has_role?({:ok, user}, &1))

  defp has_role?({:ok, user}, role) when is_atom(role), do: has_role?(user, Atom.to_string(role))
  defp has_role?(%{role: role}, role), do: true
  defp has_role?(_user, _role), do: false

  defp maybe_halt(true, conn), do: conn

  defp maybe_halt(_any, conn) do
    conn
    |> put_flash(:error, "You are not authorized")
    |> redirect(to: Routes.dashboard_path(conn, :index))
    |> halt()
  end
end
