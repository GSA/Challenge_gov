defmodule Web.Admin.DashboardController do
  use Web, :controller

  def index(conn, _params) do
    %{current_user: user} = conn.assigns
    # redirect(conn, to: Routes.admin_challenge_path(conn, :index))
    conn
    |> assign(:user, user)
    |> assign(:filter, nil)
    |> assign(:sortgh6, nil)
    |> render("index.html")
  end
end
