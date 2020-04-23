defmodule Web.Admin.ReportsController do
  use Web, :controller

  alias ChallengeGov.Reports
  alias Web.Admin.ReportsView

  def new(conn, _params) do
    %{current_user: user} = conn.assigns

    months =
      Enum.reduce(1..12, [], fn num, acc ->
        Enum.concat(acc, [{Timex.month_name(num), num}])
      end)

    days = Range.new(1, 31)

    conn
    |> assign(:years, Range.new(Timex.now().year, 2017))
    |> assign(:months, months)
    |> assign(:days, days)
    |> assign(:user, user)
    |> render("index.html")
  end

  def export_security_log(conn, params) do
    csv =
      if is_nil(params),
        do: Reports.stream_all_records(),
        else: Reports.filter_by_params(params)

    conn =
      conn
      |> put_resp_header("content-disposition", "attachment; filename=security-log.csv")
      |> send_chunked(200)

    {:ok, conn} = chunk(conn, ReportsView.render("security-log-header.csv", %{}))

    {:ok, conn} =
      ChallengeGov.Repo.transaction(fn ->
        chunk_records(conn, csv)
      end)

    conn
  end

  defp chunk_records(conn, csv) do
    Enum.reduce_while(csv, conn, fn record, conn ->
      chunk = ReportsView.render("security-log-content.csv", record: record)

      case Plug.Conn.chunk(conn, chunk) do
        {:ok, conn} ->
          {:cont, conn}

        {:error, :closed} ->
          {:halt, conn}
      end
    end)
  end
end
