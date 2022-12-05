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
      |> Timex.to_datetime()

    e_date =
      end_date
      |> String.split("-")
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple()
      |> Timex.to_datetime()

    from(c in Challenge)
    |> join(:left, [c], a in assoc(c, :agency))
    |> join(:left, [c, a], s in assoc(c, :submissions))
    |> where(
      [c, a, s],
      fragment("? BETWEEN ? AND ?", c.inserted_at, ^s_date, ^e_date)
    )
    |> where([c], c.status == "published")
    |> select([c, a, s], %{
      challenge_id: c.id,
      challenge_name: c.title,
      created_date: c.inserted_at,
      start_date: ^start_date,
      end_date: ^end_date,
      listing_type: 'Full',
      submissions_count: count(s)
    })
    |> group_by([c, a, s], [
      c.id,
      c.title,
      c.inserted_at
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
        created_date: c.created_date,
        submissions: c.submissions_count,
        current_timestamp: now,
        listing_type: c.listing_type
      }
    end)
  end
end
