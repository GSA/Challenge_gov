defmodule Web.SessionController do
  use Web, :controller

  alias IdeaPortal.Accounts

  def new(conn, _params) do
    conn
    |> put_layout("session.html")
    |> render("new.html")
  end
end
