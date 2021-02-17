defmodule Web.DashboardController do
  use Web, :controller

  def index(conn, _params) do
    %{current_user: user} = conn.assigns

    conn
    |> Phoenix.Controller.put_layout(false)
    |> assign(:user, user)
    |> assign(:filter, nil)
    |> assign(:sort, nil)
    |> render("index.html")
  end
end
