defmodule Web.Public.PageController do
  use Web, :controller

  def index(conn, _params) do
    redirect(conn, external: "https://www.challenge.gov")
  end
end
