defmodule Web.FaqController do
  use Web, :controller

  def index(conn, _params) do
    %{current_user: user} = conn.assigns

    conn
    |> render("index.html")
  end
end
