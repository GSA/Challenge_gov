defmodule ChallengeGov.Reports.CreatedChallengesRange do
  @moduledoc false
  import Ecto.Query

  alias ChallengeGov.Challenges.Challenge

  def execute(params) do
    %{
      "end_date" => end_date,
      "start_date" => start_date
    } = params

    s_date =
      start_date
      |> String.split("-")
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple()
      |> Timex.to_date()

    e_date =
      end_date
      |> String.split("-")
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple()
      |> Timex.to_date()

    from(c in Challenge)
    |> join(:left, [c], a in assoc(c, :agency))
    |> join(:left, [c, a], b in assoc(c, :sub_agency))
    |> join(:left, [c, a, b], s in assoc(c, :submissions), on: s.status == "submitted")
    |> where(
      [c, a, b, s],
      fragment("? BETWEEN ? AND ?", fragment("?::date", c.inserted_at), ^s_date, ^e_date)
    )
    |> select([c, a, b, s], %{
      challenge_id: c.id,
      challenge_name: c.title,
      start_date: ^start_date,
      end_date: ^end_date,
      agency_id: c.agency_id,
      agency_name: a.name,
      sub_agency_id: c.sub_agency_id,
      sub_agency_name: b.name,
      prize_amount: c.prize_total / 100,
      created_date: c.inserted_at,
      published_date: c.published_on,
      how_to_enter_link: c.how_to_enter_link,
      external_url: c.external_url,
      status: c.status,
      sub_status: c.sub_status,
      challenge_type: c.primary_type,
      challenge_suscribers: c.gov_delivery_subscribers,
      submissions_count: count(s)
    })
    |> group_by([c, a, b, s], [
      c.id,
      c.title,
      c.agency_id,
      a.name,
      c.sub_agency_id,
      b.name,
      c.prize_total,
      c.inserted_at,
      c.published_on,
      c.how_to_enter_link,
      c.external_url,
      c.status,
      c.sub_status,
      c.primary_type,
      c.gov_delivery_subscribers
    ])
    |> ChallengeGov.Repo.all()
    |> build_data_structure()
  end

  defp build_data_structure([]), do: %{}

  defp build_data_structure(active_published_challenge_data) do
    now = DateTime.utc_now()

    Enum.map(active_published_challenge_data, fn c ->
      %{
        challenge_id: c.challenge_id,
        challenge_name: c.challenge_name,
        agency_id: c.agency_id,
        agency_name: c.agency_name,
        sub_agency_id: c.sub_agency_id,
        sub_agency_name: c.sub_agency_name,
        start_date: c.start_date,
        end_date: c.end_date,
        challenge_suscribers: c.challenge_suscribers,
        challenge_type: c.challenge_type,
        created_date: c.created_date,
        prize_amount: c.prize_amount,
        published_date: c.published_date,
        status: c.status,
        sub_status: c.sub_status,
        submissions: c.submissions_count,
        current_timestamp: now,
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
