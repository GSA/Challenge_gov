defmodule Web.GuideController do
  use Web, :controller

  def index(conn, _params) do
    %{current_user: user} = conn.assigns

    conn
    |> render("index.html")
  end

  def categoryl1(conn, _params) do
    %{current_user: user} = conn.assigns

    conn
    |> render("categoryl1.html")
  end

  def sub_categoryl1(conn, _params) do
    %{current_user: user} = conn.assigns

    conn
    |> render("sub_categoryl1.html")
  end
end
