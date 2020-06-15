defmodule Web.Public.PreviewController do
  use Web, :controller

  def index(conn, _params) do
    conn
    |> put_layout("preview.html")
    |> render("index.html")
  end
end
