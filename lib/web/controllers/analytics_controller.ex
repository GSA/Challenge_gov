defmodule Web.AnalyticsController do
  use Web, :controller

  alias ChallengeGov.Agencies
  alias ChallengeGov.Analytics

  plug(Web.Plugs.EnsureRole, [:super_admin, :admin])

  def index(conn, params) do
    %{current_user: user} = conn.assigns

    filter = Map.get(params, "filter", %{})

    agencies = Agencies.all_for_select()
    challenges = Analytics.get_challenges(filter: filter)

    earliest_year = 2000
    current_year = DateTime.utc_now().year
    years = earliest_year..current_year

    active_challenges_count = Enum.count(Analytics.active_challenges(challenges))
    archived_challenges_count = Enum.count(Analytics.archived_challenges(challenges))
    draft_challenges_count = Enum.count(Analytics.draft_challenges(challenges))

    all_challenges = Analytics.all_challenges(challenges)
    challenges_by_primary_type = Analytics.challenges_by_primary_type(challenges)
    challenges_hosted_externally = Analytics.challenges_hosted_externally(challenges)
    total_cash_prizes = Analytics.total_cash_prizes(challenges)
    challenges_by_legal_authority = Analytics.challenges_by_legal_authority(challenges)
    participating_lead_agencies = Analytics.participating_lead_agencies(challenges)
    total_prize_competitions = Analytics.total_prize_competitions(challenges)

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
    |> assign(:total_prize_competitions, total_prize_competitions)
    |> assign(:filter, filter)
    |> render("index.html")
  end
end
