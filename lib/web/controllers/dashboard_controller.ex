defmodule Web.DashboardController do
  use Web, :controller

  def index(conn, _params) do
    %{current_user: user} = conn.assigns
    # redirect(conn, to: Routes.challenge_path(conn, :index))
    conn
    |> assign(:user, user)
    |> assign(:filter, nil)
    |> assign(:sort, nil)
    |> render("index.html")
  end
end
