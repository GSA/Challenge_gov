defmodule Web.HelpController do
  use Web, :controller

  def index(conn, _params) do
    conn
    |> render("index.html")
  end

  def solver_index(conn, _params) do
    conn
    |> render("solver_index.html")
  end
end
