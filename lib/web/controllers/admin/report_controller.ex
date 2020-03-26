defmodule ChallengeGov.Admin.ReportController do
  use Web, :controller

  # alias ChallengeGov.Reports
  alias ChallengeGov.Admin.ReportView

  def new(conn, _params) do
    conn
    |> render("new.html")
  end

  def export_security_logs(conn, _params) do
    conn =
      conn
      |> put_resp_header("content-disposition", "attachment; filename=security-logs.csv")
      |> send_chunked(200)

    {:ok, conn} = chunk(conn, ReportView.render("security-logs-header.csv", %{}))

    {:ok, conn} =
      ChallengeGov.Repo.transaction(fn ->
        chunk_records(conn)
      end)

    conn
  end

  defp chunk_records(conn) do
    Enum.reduce_while(Reports.stream_all_shifts(), conn, fn shift, conn ->
      chunk = ReportView.render("security-logs-content.csv", shift: shift) # <----- this

      case Plug.Conn.chunk(conn, chunk) do
        {:ok, conn} ->
          {:cont, conn}

        {:error, :closed} ->
          {:halt, conn}
      end
    end)
  end
end
