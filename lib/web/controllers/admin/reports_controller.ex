defmodule Web.Admin.ReportsController do
  use Web, :controller

  alias ChallengeGov.Reports
  alias Web.Admin.ReportsView
  alias ChallengeGov.Reports.Report

  def new(conn, _params) do
    %{current_user: user} = conn.assigns

    [years, months, days] = generate_date_options()

    changeset = Report.changeset(%Report{}, %{"year" => nil, "month" => nil, "day" => nil})

    conn
    |> assign(:years, years)
    |> assign(:months, months)
    |> assign(:days, days)
    |> assign(:user, user)
    |> assign(:changeset, changeset)
    |> render("index.html")
  end

  def export_security_log(conn, params) do
    csv =
      if params == %{},
        do: Reports.stream_all_records(),
        else: Reports.filter_by_params(params)

    case csv do
      {:ok, records} ->
        conn =
          conn
          |> put_resp_header("content-disposition", "attachment; filename=security-log.csv")
          |> send_chunked(200)

        {:ok, conn} = chunk(conn, ReportsView.render("security-log-header.csv", %{}))

        {:ok, conn} =
          ChallengeGov.Repo.transaction(fn ->
            chunk_records(conn, records)
          end)

        conn

      {:error, changeset} ->
        [years, months, days] = generate_date_options()
        %{current_user: user} = conn.assigns

        conn
        |> assign(:years, years)
        |> assign(:months, months)
        |> assign(:days, days)
        |> assign(:user, user)
        |> assign(:changeset, changeset)
        |> render("index.html")
    end
  end

  defp chunk_records(conn, records) do
    Enum.reduce_while(records, conn, fn record, conn ->
      chunk = ReportsView.render("security-log-content.csv", record: record)

      case Plug.Conn.chunk(conn, chunk) do
        {:ok, conn} ->
          {:cont, conn}

        {:error, :closed} ->
          {:halt, conn}
      end
    end)

    conn
  end

  def generate_date_options do
    months =
      Enum.reduce(1..12, [], fn num, acc ->
        Enum.concat(acc, [{Timex.month_name(num), num}])
      end)

    days = Range.new(1, 31)
    years = Range.new(Timex.now().year, 2020)

    [years, months, days]
  end
end
