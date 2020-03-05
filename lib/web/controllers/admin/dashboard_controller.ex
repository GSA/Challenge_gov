defmodule Web.Admin.DashboardController do
  use Web, :controller

  def index(conn, _params) do
    redirect(conn, to: Routes.admin_challenge_path(conn, :index))
  end
end
