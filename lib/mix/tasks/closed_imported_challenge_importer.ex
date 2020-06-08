defmodule Mix.Tasks.ClosedImportedChallengeImporter do
  @moduledoc """
  Importer for archived challenges
  """
  @formats [
    "{0M}/{0D}/{YYYY} {h12}:{m} {AM}",
    "{M}/{D}/{YYYY} {h12}:{m} {AM}",
    "{M}/{0D}/{YYYY} {h12}:{m} {AM}",
    "{YYYY}/{0M}/{0D} {h12} {am}",
    "{YYYY}/{M}/{0D} {h12}:{m} {AM}",
    "{0M}/{0D}/{YYYY} {h12} {am}",
    "{YYYY}/{M}/{0D} {h12}:{m} {AM}",
    "{0M}/{0D}/{YYYY}"
  ]

  use Mix.Task
  alias ChallengeGov.Accounts
  alias ChallengeGov.Agencies
  alias ChallengeGov.Challenges

  def run(_file) do
    Mix.Task.run("app.start")

    result = File.read!("lib/mix/tasks/sample_data/feed-closed-imported-parsed.json")

    import_user_id = import_user().id

    case Jason.decode(result) do
      {:ok, json} ->
        json["_challenge"]
        |> Enum.map(fn challenge ->
          create_challenge(challenge, import_user_id)
        end)

      {:error, error} ->
        error
    end
  end

  @doc """
  Create a challenge based off mapped fields
  """
  def create_challenge(json, import_user_id) do
    result =
      Challenges.import_create(%{
        "imported" => true,
        "user_id" => import_user_id,
        "title" => json["challenge-title"],
        "external_url" => json["external-url"],
        "tagline" => json["tagline"],
        "legal_authority" => json["legal-authority"],
        "types" => format_types(json["type-of-challenge"]),
        "prize_total" => sanitize_prize_amount(json["total-prize-offered-cash"]),
        "non_monetary_prizes" => json["non-monetary-incentives-awarded"],
        "prize_description" => format_prize_description(json),
        "status" => "archived",
        "agency_id" => match_agency(json["agency"]),
        "federal_partners" => match_federal_partners(json["partner-agencies-federal"]),
        "non_federal_partners" => match_non_federal_partners(json["partners-non-federal"]),
        "challenge_manager_email" => find_manager_email(json),
        "challenge_manager" => json["challenge-manager"],
        "start_date" => sanitize_date(json["submission-start"]),
        "end_date" => sanitize_date(json["submission-end"]),
        "fiscal_year" => json["fiscal-year"],
        "description" => json["description"],
        "how_to_enter" => json["how-to-enter"],
        "rules" => json["rules"],
        "judging_criteria" => format_judging_criteria(json),
        "winner_information" => format_winner_information(json)
      })

    case result do
      {:ok, result} ->
        result

      {:error, error} ->
        error
    end
  end

  # TODO: check that the \n looks right

  defp format_judging_criteria(challenge) do
    criteria =
      Enum.map(0..9, fn i ->
        [
          Map.get(challenge, "judging-criteria-#{i}"),
          maybe_append(Map.get(challenge, "judging-criteria-percentage-#{i}"), "%"),
          Map.get(challenge, "judging-criteria-description-#{i}")
        ]
      end)

    criteria
    |> Enum.map(fn fields ->
      fields
      |> Enum.reject(fn field -> field == "" end)
      |> Enum.join("\n")
    end)
    |> Enum.reject(fn info -> info == "" end)
    |> Enum.join("\n\n")
  end

  defp format_prize_description(challenge) do
    prize_data =
      Enum.map(0..9, fn i ->
        [
          Map.get(challenge, "prize-name-#{i}"),
          maybe_prepend(Map.get(challenge, "prize-cash-amount-#{i}"), "$"),
          Map.get(challenge, "prize-description-#{i}")
        ]
      end)

    prize_data
    |> Enum.map(fn fields ->
      fields
      |> Enum.reject(fn field -> field == "" end)
      |> Enum.join("\n")
    end)
    |> Enum.reject(fn info -> info == "" end)
    |> Enum.join("\n\n")
  end

  defp format_winner_information(challenge) do
    winner_information =
      Enum.map(0..9, fn i ->
        [
          Map.get(challenge, "winner-name-#{i}"),
          Map.get(challenge, "winner-solution-title-#{i}"),
          Map.get(challenge, "winner-solution-link-#{i}")
        ]
      end)

    winner_information
    |> Enum.map(fn fields ->
      fields
      |> Enum.reject(fn field -> field == "" end)
      |> Enum.join("\n")
    end)
    |> Enum.reject(fn info -> info == "" end)
    |> Enum.join("\n\n")
  end

  defp maybe_prepend("", _prepend_string), do: ""

  defp maybe_prepend(string, prepend_string) do
    "#{prepend_string}#{string}"
  end

  defp maybe_append("", _append_string), do: ""

  defp maybe_append(string, append_string) do
    "#{string}#{append_string}"
  end

  defp find_manager_email(challenge) do
    case Map.has_key?(challenge, "challenge-manager-email") do
      true ->
        challenge["challenge-manager-email"]

      false ->
        ""
    end
  end

  defp match_agency(name) do
    if name == "" do
      nil
    else
      case Agencies.get_by_name(name) do
        {:ok, agency} ->
          agency.id

        {:error, :not_found} ->
          fuzzy_match_agency(name)
      end
    end
  end

  defp fuzzy_match_agency(name) do
    agencies = Agencies.all_for_select()

    match =
      Enum.find(agencies, fn x ->
        String.jaro_distance(x.name, name) >= 0.9
      end)

    if match != nil do
      match.id
    else
      create_new_agency(name)
    end
  end

  defp create_new_agency(name) do
    {:ok, agency} =
      Agencies.create(:saved_to_file, %{
        name: "#{name}",
        created_on_import: true
      })

    agency.id
  end

  defp match_federal_partners(""), do: ""

  defp match_federal_partners(partners) do
    partner_list = String.split(partners, ",")

    Enum.map(partner_list, fn x ->
      match_agency(String.trim(x))
    end)
  end

  defp match_non_federal_partners(""), do: ""

  defp match_non_federal_partners(partners) do
    partner_list = String.split(partners, ",")

    partner_list
    |> Stream.with_index()
    |> Enum.reduce(%{}, fn {partner, idx}, acc ->
      Map.put(acc, to_string(idx), %{"name" => String.trim(partner)})
    end)
  end

  defp sanitize_date(""), do: ""

  defp sanitize_date(date) do
    # replace all spaces with single space and rm "."
    formatted_date =
      date
      |> String.replace(~r/\s+/, " ")
      |> String.replace(~r/\.+/, "")

    utc_datetime =
      Enum.find_value(@formats, fn format ->
        case Timex.parse(formatted_date, format) do
          {:ok, parsed_time} ->
            {:ok, utc_datetime} = DateTime.from_naive(parsed_time, "Etc/UTC")
            utc_datetime

          {:error, _} ->
            false
        end
      end)

    case utc_datetime do
      nil ->
        ""

      utc_datetime ->
        utc_datetime
    end
  end

  defp sanitize_prize_amount(""), do: ""

  defp sanitize_prize_amount(prize) do
    {number, _float} =
      prize
      |> String.replace(~r"(?=.*)\,(?=.*)", "")
      |> String.replace(~r"(?=.*)\$(?=.*)", "")
      |> Integer.parse()

    number
  end

  defp format_types(""), do: ""

  defp format_types(types) do
    types
    |> String.split(";")
    |> Enum.map(fn x -> String.trim(x) end)
  end

  def import_user() do
    case Accounts.get_by_email("importer@challenge.gov") do
      {:error, :not_found} ->
        {:ok, user} = Accounts.system_create(%{
          email: "importer@challenge.gov",
          first_name: "Importer",
          last_name: "User",
          role: "challenge_owner",
          terms_of_use: DateTime.truncate(DateTime.utc_now(), :second),
          privacy_guidelines: DateTime.truncate(DateTime.utc_now(), :second),
          status: "active"
        })
        user

      {:ok, user} ->
        user
    end
  end
end
