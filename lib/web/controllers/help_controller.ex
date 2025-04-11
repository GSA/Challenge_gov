defmodule Web.HelpController do
  use Web, :controller

  def index(conn, _params) do
    %{current_user: user} = conn.assigns

    conn
    |> render("index.html")
  end

  def solver_index(conn, _params) do
    %{current_user: user} = conn.assigns

    conn
    |> render("solver_index.html")
  end
end
