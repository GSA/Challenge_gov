defmodule Web.FallbackController do
  use Web, :controller

  alias Web.ErrorView

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(404)
    |> put_view(ErrorView)
    |> render(:"404")
  end

  def call(conn, {:error, _error}) do
    conn
    |> put_status(500)
    |> put_view(ErrorView)
    |> render(:"500")
  end
end
