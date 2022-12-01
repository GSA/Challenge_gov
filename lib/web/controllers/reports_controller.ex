defmodule Web.ReportsController do
  use Web, :controller

  alias ChallengeGov.SecurityLogs
  alias ChallengeGov.CertificationLogs
  alias Web.ReportsView
  alias ChallengeGov.Reports.Report
  alias ChallengeGov.Reports

  plug(Web.Plugs.EnsureRole, [:super_admin, :admin])

  def pmo_page(conn, _params) do
    %{current_user: user} = conn.assigns

    [years, months, days] = generate_date_options()

    changeset = Report.changeset(%Report{}, %{"year" => nil, "month" => nil, "day" => nil})

    conn
    |> assign(:years, years)
    |> assign(:months, months)
    |> assign(:days, days)
    |> assign(:user, user)
    |> assign(:changeset, changeset)
    |> render("pmo.html")
  end

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

  def pmo_report_name(conn, params) do
    report_name = Map.get(params, "id", nil)

    csv =
      case report_name do
        "publish-active-challenge" ->
          records =
            ChallengeGov.PublishedActiveChallenges.execute(params)
            {:ok, records}

        "published-date-range" ->
         records =
          ChallengeGov.PublishedChallengesRange.execute(params)
          {:ok, records}
        "created-date-range" ->

          records =
            ChallengeGov.CreatedChallengesRange.execute(params)
            {:ok, records}

        "number-of-submissions-challenge" ->
          records =
            ChallengeGov.NumberOfSubmissions.execute(params)
            {:ok, records}
      end



    case csv do
      {:ok, records} ->
        conn =
          conn
          |> put_resp_header("content-disposition", "attachment; filename=#{report_name}.csv")
          |> send_chunked(200)

        {:ok, conn} = chunk(conn, ReportsView.render_query_log("#{report_name}-header.csv", %{}))

        {:ok, conn} =
          ChallengeGov.Repo.transaction(fn ->
            chunk_records(conn, records, "#{report_name}-content.csv")
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

  def export_security_log(conn, params) do
    csv =
      if params == %{},
        do: SecurityLogs.stream_all_records(),
        else: SecurityLogs.filter_by_params(params)

    case csv do
      {:ok, records} ->
        conn =
          conn
          |> put_resp_header("content-disposition", "attachment; filename=security-log.csv")
          |> send_chunked(200)

        {:ok, conn} = chunk(conn, ReportsView.render_security_log("security-log-header.csv", %{}))

        {:ok, conn} =
          ChallengeGov.Repo.transaction(fn ->
            chunk_records(conn, records, "security-log-content.csv")
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

  defp chunk_records(conn, records, file_name) do
    _records =
      Enum.reduce_while(records, conn, fn record, conn ->
        chunk = ReportsView.render(file_name, record: record)
        case Plug.Conn.chunk(conn, chunk) do
          {:ok, conn} ->
            {:cont, conn}

          {:error, :closed} ->
            {:halt, conn}
        end
      end)

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
