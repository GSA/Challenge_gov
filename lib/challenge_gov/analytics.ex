defmodule ChallengeGov.Analytics do
  @moduledoc """
  Analytics context
  """
  @behaviour Stein.Filter

  import Ecto.Query

  alias ChallengeGov.Challenges.Challenge
  alias ChallengeGov.Repo
  alias Stein.Filter

  def get_challenges(opts \\ []) do
    Challenge
    |> where([c], not is_nil(c.start_date))
    |> where([c], not is_nil(c.end_date))
    |> Filter.filter(opts[:filter], __MODULE__)
    |> Repo.all()
  end

  def active_challenges(all_challenges) do
    Enum.filter(all_challenges, fn challenge ->
      challenge.status == "published" and
        (challenge.sub_status == "open" or challenge.sub_status == "closed")
    end)
  end

  def archived_challenges(all_challenges) do
    Enum.filter(all_challenges, fn challenge ->
      challenge.status == "published" and challenge.sub_status == "archived"
    end)
  end

  def draft_challenges(all_challenges) do
    Enum.filter(all_challenges, fn challenge ->
      challenge.status == "draft"
    end)
  end

  def launched_in_year?(challenge, year) do
    challenge.start_date.year == year
  end

  def ongoing_in_year?(challenge, year) do
    challenge.start_date.year < year and
      challenge.end_date.year > year
  end

  def closed_in_year?(challenge, year) do
    challenge.end_date.year == year
  end

  def all_challenges(challenges) do
    grouped_challenges =
      challenges
      |> Enum.filter(fn challenge -> !is_nil(challenge.start_date) end)
      |> Enum.group_by(fn challenge -> challenge.start_date.year end)
      |> Enum.reduce(%{}, fn {year, challenges}, acc ->
        Map.put(acc, year, Enum.count(challenges))
      end)

    labels = Map.keys(grouped_challenges)
    data = Map.values(grouped_challenges)

    data_obj = %{
      labels: labels,
      datasets: [
        %{
          data: data
        }
      ]
    }

    options_obj = [
      options: %{
        plugins: %{
          title: %{
            display: true,
            text: "All challenges"
          }
        }
      }
    ]

    %{
      data: data_obj,
      options: options_obj
    }
  end

  def challenges_by_primary_type(challenges) do
    grouped_challenges =
      challenges
      |> Enum.filter(fn challenge -> !is_nil(challenge.start_date) end)
      |> Enum.group_by(fn challenge -> challenge.primary_type end)
      |> Enum.reduce(%{}, fn {primary_type, challenges}, acc ->
        Map.put(acc, primary_type, Enum.count(challenges))
      end)

    labels = Map.keys(grouped_challenges)
    data = Map.values(grouped_challenges)

    data_obj = %{
      labels: labels,
      datasets: [
        %{
          data: data
        }
      ]
    }

    options_obj = [
      options: %{
        indexAxis: "y",
        plugins: %{
          title: %{
            display: true,
            text: "Challenges by primary type"
          }
        }
      }
    ]

    %{
      data: data_obj,
      options: options_obj
    }
  end

  def challenges_hosted_externally(challenges) do
    challenges =
      Enum.filter(challenges, fn challenge ->
        !is_nil(challenge.start_date) and !is_nil(challenge.external_url)
      end)

    grouped_challenges =
      challenges
      |> Enum.group_by(fn challenge -> challenge.start_date.year end)
      |> Enum.reduce(%{}, fn {year, challenges}, acc ->
        Map.put(acc, year, Enum.count(challenges))
      end)

    labels = Map.keys(grouped_challenges)
    data = Map.values(grouped_challenges)

    data_obj = %{
      labels: labels,
      datasets: [
        %{
          data: data
        }
      ]
    }

    options_obj = [
      options: %{
        plugins: %{
          title: %{
            display: true,
            text: "Challenges hosted externally"
          }
        }
      }
    ]

    %{
      data: data_obj,
      options: options_obj
    }
  end

  def total_cash_prizes(challenges) do
    challenges = Enum.filter(challenges, fn challenge -> !is_nil(challenge.start_date) end)

    grouped_challenges =
      challenges
      |> Enum.group_by(fn challenge -> challenge.start_date.year end)
      |> Enum.reduce(%{}, fn {year, challenges}, acc ->
        total_prize_amount =
          challenges
          |> Enum.map(fn challenge -> challenge.prize_total || 0 end)
          |> Enum.sum()

        Map.put(acc, year, total_prize_amount / 1000)
      end)

    labels = Map.keys(grouped_challenges)
    data = Map.values(grouped_challenges)

    data_obj = %{
      labels: labels,
      datasets: [
        %{
          data: data
        }
      ]
    }

    options_obj = [
      options: %{
        plugins: %{
          title: %{
            display: true,
            text: "Total cash prizes"
          },
          legend: %{
            display: false
          },
          scales: %{
            y: %{
              beginAtZero: true
            }
          }
        }
      }
    ]

    %{
      data: data_obj,
      options: options_obj
    }
  end

  def challenges_by_legal_authority(challenges) do
    challenges =
      Enum.filter(challenges, fn challenge ->
        !is_nil(challenge.start_date) and !is_nil(challenge.legal_authority)
      end)

    labels =
      challenges
      |> Enum.group_by(fn challenge -> challenge.start_date.year end)
      |> Enum.sort_by(fn {year, _} -> year end)
      |> Enum.uniq_by(fn {year, _} -> year end)
      |> Enum.map(fn {year, _} -> year end)

    data =
      challenges
      |> Enum.group_by(fn challenge -> challenge.legal_authority end)
      |> Enum.reduce([], fn {legal_authority, challenges}, acc ->
        grouped_challenges =
          Enum.group_by(challenges, fn challenge -> challenge.start_date.year end)

        data =
          labels
          |> Enum.map(fn year ->
            grouped_challenges = grouped_challenges[year] || []
            Enum.count(grouped_challenges)
          end)

        data = %{
          label: legal_authority,
          data: data
        }

        acc ++ [data]
      end)

    data_obj = %{
      labels: labels,
      datasets: data
    }

    options_obj = [
      options: %{
        plugins: %{
          title: %{
            display: true,
            text: "Challenges by legal authority"
          },
          legend: %{
            display: true,
            position: "bottom"
          }
        }
      }
    ]

    %{
      data: data_obj,
      options: options_obj
    }
  end

  def participating_lead_agencies(challenges) do
    challenges =
      Enum.filter(challenges, fn challenge ->
        !is_nil(challenge.start_date) and !is_nil(challenge.end_date) and
          !is_nil(challenge.agency_id)
      end)

    min_year =
      Enum.min_by(challenges, fn challenge -> challenge.start_date.year end).start_date.year

    max_year = Enum.max_by(challenges, fn challenge -> challenge.end_date.year end).end_date.year
    year_range = Enum.to_list(min_year..max_year)

    labels = year_range

    launched_data =
      year_range
      |> Enum.map(fn year ->
        challenges
        |> Enum.filter(fn challenge -> launched_in_year?(challenge, year) end)
        |> Enum.uniq_by(fn challenge -> challenge.agency_id end)
        |> Enum.count()
      end)

    ongoing_data =
      year_range
      |> Enum.map(fn year ->
        challenges
        |> Enum.filter(fn challenge -> ongoing_in_year?(challenge, year) end)
        |> Enum.uniq_by(fn challenge -> challenge.agency_id end)
        |> Enum.count()
      end)

    closed_data =
      year_range
      |> Enum.map(fn year ->
        challenges
        |> Enum.filter(fn challenge -> closed_in_year?(challenge, year) end)
        |> Enum.uniq_by(fn challenge -> challenge.agency_id end)
        |> Enum.count()
      end)

    data = [
      %{
        label: "Launched",
        data: launched_data
      },
      %{
        label: "Ongoing",
        data: ongoing_data
      },
      %{
        label: "Closed",
        data: closed_data
      }
    ]

    data_obj = %{
      labels: labels,
      datasets: data
    }

    options_obj = [
      options: %{
        plugins: %{
          title: %{
            display: true,
            text: "Total number of participating lead agencies"
          },
          legend: %{
            display: true,
            position: "bottom"
          }
        }
      }
    ]

    %{
      data: data_obj,
      options: options_obj
    }
  end

  @impl Stein.Filter
  def filter_on_attribute({"agency_id", value}, query) do
    where(query, [c], c.agency_id == ^value)
  end

  def filter_on_attribute({"year_filter", value}, query) do
    query
    |> maybe_filter_start_year(value)
    |> maybe_filter_end_year(value)
  end

  defp maybe_filter_start_year(query, %{"start_year" => ""}), do: query

  defp maybe_filter_start_year(query, %{"target_date" => "start", "start_year" => year}) do
    {year, _} = Integer.parse(year)
    where(query, [c], fragment("DATE_PART('year', ?)", c.start_date) >= ^year)
  end

  defp maybe_filter_start_year(query, %{"target_date" => "end", "start_year" => year}) do
    {year, _} = Integer.parse(year)
    where(query, [c], fragment("DATE_PART('year', ?)", c.end_date) >= ^year)
  end

  defp maybe_filter_end_year(query, %{"end_year" => ""}), do: query

  defp maybe_filter_end_year(query, %{"target_date" => "start", "end_year" => year}) do
    {year, _} = Integer.parse(year)
    where(query, [c], fragment("DATE_PART('year', ?)", c.start_date) <= ^year)
  end

  defp maybe_filter_end_year(query, %{"target_date" => "end", "end_year" => year}) do
    {year, _} = Integer.parse(year)
    where(query, [c], fragment("DATE_PART('year', ?)", c.end_date) <= ^year)
  end
end
