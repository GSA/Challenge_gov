defmodule Web.Plugs.VerifyAdmin do
  @moduledoc """
  Verify a _admin_ user is in the session
  """

  import Plug.Conn
  import Phoenix.Controller

  alias IdeaPortal.Accounts
  alias Web.ErrorView
  alias Web.LayoutView

  def init(default), do: default

  def call(conn, _opts) do
    case is_admin?(conn) do
      true ->
        conn

      false ->
        conn
        |> put_status(:not_found)
        |> put_layout({LayoutView, "app.html"})
        |> put_view(ErrorView)
        |> render("404.html")
        |> halt()
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
