defmodule Web.AnalyticsController do
  use Web, :controller

  alias ChallengeGov.Agencies
  alias ChallengeGov.Analytics
  alias ChallengeGov.Reports.DapReports

  plug(Web.Plugs.EnsureRole, [:super_admin, :admin, :challenge_manager])

  def index(conn, params) do
    %{current_user: user} = conn.assigns

    filter = Map.get(params, "filter", %{})

    year_filter =
      Map.get(filter, "year_filter", %{
        "target_date" => "start",
        "start_year" => "2010",
        "end_year" => ""
      })

    filter = Map.put(filter, "year_filter", year_filter)

    agencies = Agencies.all_for_select()
    challenges = Analytics.get_challenges(filter: filter)

    earliest_year = Analytics.default_start_year()
    current_year = Analytics.default_end_year()
    years = earliest_year..current_year

    filter_start_year = Map.get(year_filter, "start_year", "")
    filter_end_year = Map.get(year_filter, "end_year", "")
    filter_year_range = Analytics.get_year_range(filter_start_year, filter_end_year)

    active_challenges_count = Enum.count(Analytics.active_challenges(challenges))
    archived_challenges_count = Enum.count(Analytics.archived_challenges(challenges))
    draft_challenges_count = Enum.count(Analytics.draft_challenges(challenges))

    all_challenges = Analytics.all_challenges(challenges, filter_year_range)

    challenges_by_primary_type =
      Analytics.challenges_by_primary_type(challenges, filter_year_range)

    challenges_hosted_externally =
      Analytics.challenges_hosted_externally(challenges, filter_year_range)

    total_cash_prizes = Analytics.total_cash_prizes(challenges, filter_year_range)

    challenges_by_legal_authority =
      Analytics.challenges_by_legal_authority(challenges, filter_year_range)

    participating_lead_agencies =
      Analytics.participating_lead_agencies(challenges, filter_year_range)

    dap_reports = DapReports.all_last_six_months()

    conn
    |> assign(:user, user)
    |> assign(:agencies, agencies)
    |> assign(:years, years)
    |> assign(:active_challenges_count, active_challenges_count)
    |> assign(:archived_challenges_count, archived_challenges_count)
    |> assign(:draft_challenges_count, draft_challenges_count)
    |> assign(:all_challenges, all_challenges)
    |> assign(:challenges_by_primary_type, challenges_by_primary_type)
    |> assign(:challenges_hosted_externally, challenges_hosted_externally)
    |> assign(:total_cash_prizes, total_cash_prizes)
    |> assign(:challenges_by_legal_authority, challenges_by_legal_authority)
    |> assign(:participating_lead_agencies, participating_lead_agencies)
    |> assign(:dap_reports, dap_reports)
    |> assign(:filter, filter)
    |> render("index.html")
  end
end
