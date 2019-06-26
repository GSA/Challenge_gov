defmodule Web.Admin.FallbackController do
  use Web, :controller

  require Logger

  alias Web.Admin.ErrorView

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(404)
    |> put_view(ErrorView)
    |> render(:"404")
  end

  def call(conn, {:error, error}) do
    Logger.warn("A fall through error was encountered - #{inspect(error)}")

    conn
    |> put_status(500)
    |> put_view(ErrorView)
    |> render(:"500-fallthrough")
  end
end
