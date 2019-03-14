defmodule Web.PageController do
  use Web, :controller

  def index(conn, _params) do
    redirect(conn, to: Routes.challenge_path(conn, :index))
  end
end
