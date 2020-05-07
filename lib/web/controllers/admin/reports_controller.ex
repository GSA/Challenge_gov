defmodule Web.Admin.ReportsController do
  use Web, :controller

  alias ChallengeGov.SecurityLogs
  alias ChallengeGov.CertificationLogs
  alias Web.Admin.ReportsView

  def new(conn, _params) do
    %{current_user: user} = conn.assigns

    months =
      Enum.reduce(1..12, [], fn num, acc ->
        Enum.concat(acc, [{Timex.month_name(num), num}])
      end)

    days = Range.new(1, 31)

    conn
    |> assign(:years, Range.new(Timex.now().year, 2020))
    |> assign(:months, months)
    |> assign(:days, days)
    |> assign(:user, user)
    |> render("index.html")
  end

  def export_security_log(conn, params) do
    csv =
      if params == %{},
        do: SecurityLogs.stream_all_records(),
        else: SecurityLogs.filter_by_params(params)

    conn =
      conn
      |> put_resp_header("content-disposition", "attachment; filename=security-log.csv")
      |> send_chunked(200)

    {:ok, conn} = chunk(conn, ReportsView.render_security_log("security-log-header.csv", %{}))

    {:ok, conn} =
      ChallengeGov.Repo.transaction(fn ->
        chunk_records(conn, csv, "security-log-content.csv")
      end)

    conn
  end

  def export_certification_log(conn, params) do
    csv =
      if params == %{},
        do: CertificationLogs.stream_all_records(),
        else: CertificationLogs.filter_by_params(params)

    conn =
      conn
      |> put_resp_header("content-disposition", "attachment; filename=certification-log.csv")
      |> send_chunked(200)

    {:ok, conn} =
      chunk(conn, ReportsView.render_certification_log("certification-log-header.csv", %{}))

    {:ok, conn} =
      ChallengeGov.Repo.transaction(fn ->
        chunk_records(conn, csv, "certification-log-content.csv")
      end)

    conn
  end

  defp chunk_records(conn, csv, file_name) do
    Enum.reduce_while(csv, conn, fn record, conn ->
      chunk = ReportsView.render(file_name, record: record)

      case Plug.Conn.chunk(conn, chunk) do
        {:ok, conn} ->
          {:cont, conn}

        {:error, :closed} ->
          {:halt, conn}
      end
    end)
  end
end
