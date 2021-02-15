defmodule Web.DashboardController do
  use Web, :controller

  def index(conn, _params) do
    IO.inspect("CONN")
    IO.inspect(conn)
    IO.inspect("question: why isn't the conn layout root correct?")
    conn = put_root_layout(conn, {Web.LayoutView, :root})
    conn = put_new_layout(conn, {Web.LayoutView, :root})
    IO.inspect("NEW CONN")
    IO.inspect(conn)
    %{current_user: user} = conn.assigns
    # redirect(conn, to: Routes.challenge_path(conn, :index))
    conn
    |> assign(:user, user)
    |> assign(:filter, nil)
    |> assign(:sort, nil)
    |> render("index.html")
  end
end
