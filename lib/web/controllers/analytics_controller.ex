defmodule Web.AnalyticsController do
  use Web, :controller

  plug(Web.Plugs.EnsureRole, [:super_admin, :admin])

  def index(conn, _params) do
    %{current_user: user} = conn.assigns

    conn
    |> assign(:user, user)
    |> render("index.html")
  end
end
