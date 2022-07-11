defmodule ChallengeGov.Analytics do
  @moduledoc """
  Analytics context
  """
  @behaviour Stein.Filter

  import Ecto.Query

  alias ChallengeGov.Challenges.Challenge
  alias ChallengeGov.Repo
  alias Stein.Filter

  @prussian_blue "#112F4E"
  @deep_saffron "#FA9441"
  @french_sky_blue "#81AEFC"
  @up_maroon "#780116"
  @bittersweet "#F96462"
  @ivory "#FFFFF2"
  @eton_blue "#8BBF9F"
  @nickel "#706C61"

  @colors [
    @prussian_blue,
    @deep_saffron,
    @french_sky_blue,
    @up_maroon,
    @bittersweet,
    @ivory,
    @eton_blue,
    @nickel
  ]

  @primary_type_color_mapping %{
    "Technology demonstration and hardware" => @prussian_blue,
    "Ideas" => @deep_saffron,
    "Analytics, visualizations, algorithms" => @french_sky_blue,
    "Nominations" => @up_maroon,
    "Business plans" => @bittersweet,
    "Software and apps" => @ivory,
    "Scientific" => @eton_blue,
    "Creative (multimedia & design)" => @nickel
  }

  def get_challenges(opts \\ []) do
    Challenge
    |> where([c], not is_nil(c.start_date))
    |> where([c], not is_nil(c.end_date))
    |> Filter.filter(opts[:filter], __MODULE__)
    |> Repo.all()
  end

  def challenge_prefilter(challenges) do
    Enum.filter(challenges, fn challenge ->
      !is_nil(challenge.start_date) and !is_nil(challenge.end_date)
    end)
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

  def get_year_range(start_year, end_year) do
    start_year = get_start_year(start_year)
    end_year = get_end_year(end_year)

    Enum.to_list(start_year..end_year)
  end

  def get_start_year(""), do: default_start_year()
  def get_start_year(year), do: year_to_integer(year)

  def default_start_year, do: Repo.one(select(Challenge, [c], min(c.start_date))).year

  def get_end_year(""), do: default_end_year()
  def get_end_year(year), do: year_to_integer(year)

  def default_end_year, do: DateTime.utc_now().year

  defp year_to_integer(year) do
    {year, _} = Integer.parse(year)
    year
  end

  def calculate_prize_amount(challenge = %{imported: true}), do: challenge.prize_total || 0
  def calculate_prize_amount(challenge), do: (challenge.prize_total || 0) / 100

  def all_challenges(challenges, years) do
    challenges = challenge_prefilter(challenges)

    data =
      years
      |> Enum.reduce(%{}, fn year, acc ->
        Map.put(
          acc,
          year,
          Enum.count(challenges, fn challenge ->
            challenge.start_date.year == year
          end)
        )
      end)

    data_obj = %{
      datasets: [
        %{
          data: data,
          backgroundColor: Enum.at(@colors, 0)
        }
      ]
    }

    options_obj = []

    %{
      data: data_obj,
      options: options_obj
    }
  end

  def challenges_by_primary_type(challenges, years) do
    challenges =
      challenges
      |> challenge_prefilter()
      |> Enum.filter(fn challenge ->
        !is_nil(challenge.primary_type)
      end)

    labels = years

    data =
      challenges
      |> Enum.group_by(fn challenge -> challenge.primary_type end)

    data =
      data
      |> Enum.with_index()
      |> Enum.reduce([], fn {{primary_type, challenges}, _index}, acc ->
        grouped_challenges =
          Enum.group_by(challenges, fn challenge -> challenge.start_date.year end)

        data =
          years
          |> Enum.map(fn year ->
            grouped_challenges = grouped_challenges[year] || []
            Enum.count(grouped_challenges)
          end)

        data = %{
          label: primary_type,
          data: data,
          borderWidth: 1,
          backgroundColor: Map.get(@primary_type_color_mapping, primary_type)
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
          legend: %{
            display: true,
            position: "bottom"
          }
        },
        scales: %{
          x: %{
            stacked: true
          },
          y: %{
            stacked: true
          }
        }
      }
    ]

    %{
      data: data_obj,
      options: options_obj
    }
  end

  def challenges_hosted_externally(challenges, years) do
    challenges = challenge_prefilter(challenges)

    labels = years

    data =
      challenges
      |> Enum.group_by(fn challenge -> is_nil(challenge.external_url) end)
      |> Enum.reduce([], fn {hosted_internally, challenges}, acc ->
        grouped_challenges =
          Enum.group_by(challenges, fn challenge -> challenge.start_date.year end)

        data =
          years
          |> Enum.map(fn year ->
            grouped_challenges = grouped_challenges[year] || []
            Enum.count(grouped_challenges)
          end)

        {label, color_index} =
          if hosted_internally, do: {"Hosted on Challenge.gov", 0}, else: {"Hosted externally", 1}

        data = %{
          label: label,
          data: data,
          backgroundColor: Enum.at(@colors, color_index)
        }

        acc ++ [data]
      end)
      |> Enum.reverse()

    data_obj = %{
      labels: labels,
      datasets: data
    }

    options_obj = [
      options: %{
        plugins: %{
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

  def total_cash_prizes(challenges, years) do
    challenges =
      challenges
      |> challenge_prefilter()
      |> Enum.reject(fn c -> c.status not in ["published", "archived"] end)

    data =
      years
      |> Enum.reduce(%{}, fn year, acc ->
        total_prize_amount =
          challenges
          |> Enum.filter(fn challenge -> challenge.start_date.year == year end)
          |> Enum.map(fn challenge ->
            calculate_prize_amount(challenge)
          end)
          |> Enum.sum()

        Map.put(acc, year, total_prize_amount)
      end)

    data_obj = %{
      datasets: [
        %{
          data: data,
          backgroundColor: Enum.at(@colors, 0)
        }
      ]
    }

    options_obj = [
      options: %{
        format: "currency",
        plugins: %{
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

  def challenges_by_legal_authority(challenges, years) do
    challenges =
      challenges
      |> challenge_prefilter()
      |> Enum.filter(fn challenge ->
        !is_nil(challenge.legal_authority)
      end)

    labels = years

    data =
      challenges
      |> Enum.group_by(fn challenge ->
        challenge.legal_authority
        |> String.downcase()
        |> String.contains?("competes")
      end)
      |> Enum.reduce([], fn {is_america_competes, challenges}, acc ->
        grouped_challenges =
          Enum.group_by(challenges, fn challenge -> challenge.start_date.year end)

        data =
          years
          |> Enum.map(fn year ->
            grouped_challenges = grouped_challenges[year] || []
            Enum.count(grouped_challenges)
          end)

        {label, color_index} =
          if is_america_competes, do: {"America Competes", 0}, else: {"Other", 1}

        data = %{
          label: label,
          data: data,
          backgroundColor: Enum.at(@colors, color_index)
        }

        acc ++ [data]
      end)
      |> Enum.reverse()

    data_obj = %{
      labels: labels,
      datasets: data
    }

    options_obj = [
      options: %{
        plugins: %{
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

  def participating_lead_agencies(challenges, years) do
    challenges =
      challenges
      |> challenge_prefilter()
      |> Enum.filter(fn challenge -> !is_nil(challenge.agency_id) end)

    labels = years

    launched_data =
      years
      |> Enum.map(fn year ->
        challenges
        |> Enum.filter(fn challenge -> launched_in_year?(challenge, year) end)
        |> Enum.uniq_by(fn challenge -> challenge.agency_id end)
        |> Enum.count()
      end)

    data = [
      %{
        data: launched_data,
        backgroundColor: Enum.at(@colors, 0)
      }
    ]

    data_obj = %{
      labels: labels,
      datasets: data
    }

    options_obj = []

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
