defmodule ChallengeGov.Reports.NumberOfSubmissions do
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
    |> join(:left, [c, a], s in assoc(c, :submissions), on: s.status == "submitted")
    |> where(
      [c, a, s],
      fragment("? BETWEEN ? AND ?", fragment("?::date", s.inserted_at), ^s_date, ^e_date)
    )
    |> where([c], is_nil(c.how_to_enter_link) and is_nil(c.external_url))
    |> select([c, a, s], %{
      challenge_id: c.id,
      challenge_name: c.title,
      start_date: ^start_date,
      end_date: ^end_date,
      listing_type: 'Full',
      submissions_count: count(s)
    })
    |> group_by([c, a, s], [
      c.id,
      c.title
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
        start_date: c.start_date,
        end_date: c.end_date,
        submissions: c.submissions_count,
        current_timestamp: now,
        listing_type: c.listing_type
      }
    end)
  end
end
