defmodule Mix.Tasks.ClosedChallengeImporter do
  @moduledoc """
  Importer for archived challenges
  """
  use Mix.Task
  alias ChallengeGov.Agencies
  alias ChallengeGov.Challenges
  alias ChallengeGov.HTTPClient

  def run(_file) do
    Mix.Task.run("app.start")

    result = File.read!("lib/mix/tasks/sample_data/feed-closed-parsed.json")

    case Jason.decode(result) do
      {:ok, json} ->
        json["_challenge"]
        |> Enum.with_index()
        |> Enum.map(fn {challenge, _idx} ->
          create_challenge(challenge)
        end)

      {:error, error} ->
        error
    end
  end

  @doc """
  Create a challenge based off mapped fields
  """
  def create_challenge(json) do
    result =
      Challenges.create(%{
        "user_id" => 0,
        "status" => "closed",
        "challenge_manager" => json["challenge-manager,"],
        "challenge_manager_email" => json["challenge-manager-email"],
        "poc_email" => json["point-of-contact"],
        "agency_id" => match_agency(json["agency"], json["agency-logo"]),
        "logo" => prep_logo(json["card-image"]),
        "federal_partners" => match_federal_partners(json["partner-agencies-federal"]),
        "non_federal_partners" => match_non_federal_partners(json["partners-non-federal"]),
        "title" => json["challenge-title"],
        "external_url" => json["external-url"],
        "tagline" => json["tagline"],
        "description" => json["description"],
        "how_to_enter" => json["how-to-enter"],
        "fiscal_year" => json["fiscal-year"],
        "start_date" => sanitize_date(json["submission-start"]),
        "end_date" => sanitize_date(json["submission-end"]),
        "judging_criteria" => json["judging"],
        "prize_total" => sanitize_prize_amount(json["total-prize-offered-cash"]),
        "non_monetary_prizes" => json["prizes"],
        "rules" => json["rules"],
        "legal_authority" => json["legal-authority"],
        "types" => format_types(json["type-of-challenge"])
      })

    case result do
      {:ok, result} ->
        result

      {:error, error} ->
        error
    end
  end

  defp match_agency(name, logo \\ nil) do
    case Agencies.get_by_name(name) do
      {:ok, agency} ->
        agency.id

      {:error, :not_found} ->
        fuzzy_match_agency(name, logo)
    end
  end

  defp fuzzy_match_agency(name, logo) do
    agencies = Agencies.all_for_select()

    match =
      Enum.find(agencies, fn x ->
        String.jaro_distance(x.name, name) >= 0.9
      end)

    if !is_nil(match) do
      match.id
    else
      create_new_agency(name, logo)
    end
  end

  defp create_new_agency(name, logo) when is_nil(logo) do
    {:ok, agency} =
      Agencies.create(:saved_to_file, %{
        name: "#{name}"
      })

    agency.id
  end

  defp create_new_agency(name, logo_url) do
    filename = Path.basename(logo_url)
    extension = Path.extname(filename)

    {:ok, tmp_file} = Stein.Storage.Temp.create(extname: extension)

    response =
      Finch.request(
        HTTPClient,
        :get,
        "https://www.challenge.gov/assets/netlify-uploads/#{filename}"
      )

    case response do
      {:ok, %{status: 200, body: body}} ->
        File.write!(tmp_file, body, [:binary])

        {:ok, agency} = Agencies.create(:saved_to_file, %{avatar: %{path: tmp_file}, name: name})
        agency.id

      _ ->
        {:ok, agency} = Agencies.create(:saved_to_file, %{name: name})
        agency.id
    end
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

  defp prep_logo(""), do: ""

  defp prep_logo(logo_url) do
    filename = Path.basename(logo_url)
    extension = Path.extname(filename)

    {:ok, tmp_file} = Stein.Storage.Temp.create(extname: extension)

    with {:ok, %{status: 200, body: body}} <- Finch.request(HTTPClient, :get, logo_url) do
      File.write!(tmp_file, body, [:binary])

      %{
        filename: filename,
        path: tmp_file
      }
    else
      {:ok, %{status: 404}} ->
        ""
    end
  end

  defp sanitize_date(""), do: ""

  defp sanitize_date(date) do
    # set all spaces to single spaces
    single_space_date = String.replace(date, ~r/\s+/, " ")

    # alt to above: find double spaces and replace
    # single_space_date = String.replace(date, ~r/[ \t]{2,}/, " ")

    # rm "."
    formatted_date = String.replace(single_space_date, ~r/\.+/, "")

    case Timex.parse(formatted_date, "{0M}/{0D}/{YYYY} {h12}:{m} {AM}") do
      {:ok, parsed_date} ->
        {:ok, utc_date} = DateTime.from_naive(parsed_date, "Etc/UTC")
        utc_date

      {:error, _error} ->
        case Timex.parse(formatted_date, "{M}/{D}/{YYYY} {h12}:{m} {AM}") do
          {:ok, parsed_date} ->
            {:ok, utc_date} = DateTime.from_naive(parsed_date, "Etc/UTC")
            utc_date

          {:error, _error} ->
            case Timex.parse(formatted_date, "{M}/{0D}/{YYYY} {h12}:{m} {AM}") do
              {:ok, parsed_date} ->
                {:ok, utc_date} = DateTime.from_naive(parsed_date, "Etc/UTC")
                utc_date

              {:error, _error} ->
                case Timex.parse(formatted_date, "{YYYY}/{0M}/{0D} {h12} {am}") do
                  {:ok, parsed_date} ->
                    {:ok, utc_date} = DateTime.from_naive(parsed_date, "Etc/UTC")
                    utc_date

                  {:error, _error} ->
                    case Timex.parse(formatted_date, "{YYYY}/{M}/{0D} {h12}:{m} {AM}") do
                      {:ok, parsed_date} ->
                        {:ok, utc_date} = DateTime.from_naive(parsed_date, "Etc/UTC")
                        utc_date

                      {:error, _error} ->
                        case Timex.parse(formatted_date, "{0M}/{0D}/{YYYY} {h12} {am}") do
                          {:ok, parsed_date} ->
                            {:ok, utc_date} = DateTime.from_naive(parsed_date, "Etc/UTC")
                            utc_date

                          {:error, _error} ->
                            case Timex.parse(formatted_date, "{YYYY}/{M}/{0D} {h12}:{m} {AM}") do
                              {:ok, parsed_date} ->
                                {:ok, utc_date} = DateTime.from_naive(parsed_date, "Etc/UTC")
                                utc_date

                              {:error, _error} ->
                                case Timex.parse(formatted_date, "{0M}/{0D}/{YYYY}") do
                                  {:ok, parsed_date} ->
                                    {:ok, utc_date} = DateTime.from_naive(parsed_date, "Etc/UTC")
                                    utc_date

                                  {:error, error} ->
                                    IO.puts("no case for this format")
                                end
                            end
                        end
                    end
                end
            end
        end
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
    String.split(types, ";")
    |> Enum.map(fn x -> String.trim(x) end)
  end
end
