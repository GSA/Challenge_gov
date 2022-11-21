defmodule ChallengeGov.PublishedActiveChallenges do
  @moduledoc false
  import Ecto.Query

  alias ChallengeGov.Challenges.Challenge

  def execute(params) do
    from(c in Challenge)
    |> join(:left, [c], a in assoc(c, :agency))
    |> join(:left, [c, a], s in assoc(c, :submissions))
    |> where(
      [c, a, s],
      fragment("? BETWEEN ? AND ?", c.start_date, ^params.start_date, ^params.end_date)
    )
    |> select([c, a, s], %{
      agency_name: a.name,
      prize_amount: c.prize_total,
      created_at: c.inserted_at,
      published_date: c.published_on,
      how_to_enter_link: c.how_to_enter_link,
      external_url: c.external_url,
      status: c.status,
      challenge_type: c.primary_type,
      challenge_suscribers: c.gov_delivery_subscribers,
      submissions_count: count(s)
    })
    |> group_by([c, a, s], [
      a.name,
      c.prize_total,
      c.inserted_at,
      c.published_on,
      c.how_to_enter_link,
      c.external_url,
      c.status,
      c.primary_type,
      c.gov_delivery_subscribers
    ])
    |> ChallengeGov.Repo.all()
    |> build_data_structure()
  end

  defp build_data_structure([]), do: %{}

  defp build_data_structure(active_published_challenge_data) do
    Enum.map(active_published_challenge_data, fn c ->
      %{
        agency_name: c.agency_name,
        challenge_suscribers: c.challenge_suscribers,
        challenge_type: c.challenge_type,
        created_at: c.created_at,
        prize_amount: c.prize_amount,
        published_date: c.published_date,
        status: c.status,
        submissions_count: c.submissions_count,
        listing_type:
          set_listing_type(
            c.how_to_enter_link,
            c.external_url
          )
      }
    end)
  end

  def set_listing_type(nil, nil), do: "Full"
  def set_listing_type(_, nil), do: "Hybrid"
  def set_listing_type(_, _), do: "Title Only"
end
