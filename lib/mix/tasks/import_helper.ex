require Logger

defmodule Mix.Tasks.ImportHelper do
  @moduledoc """
  Helper for archived challenge importers
  """

  alias ChallengeGov.Accounts
  alias ChallengeGov.Agencies
  alias ChallengeGov.Challenges.Challenge
  alias ChallengeGov.HTTPClient

  @date_formats [
    "{0M}/{0D}/{YYYY} {h12}:{m} {AM}",
    "{M}/{D}/{YYYY} {h12}:{m} {AM}",
    "{M}/{0D}/{YYYY} {h12}:{m} {AM}",
    "{YYYY}/{0M}/{0D} {h12} {am}",
    "{YYYY}/{M}/{0D} {h12}:{m} {AM}",
    "{0M}/{0D}/{YYYY} {h12} {am}",
    "{YYYY}/{M}/{0D} {h12}:{m} {AM}",
    "{0M}/{0D}/{YYYY}"
  ]

  # Import User Helper
  def import_user() do
    case Accounts.get_by_email("importer@challenge.gov") do
      {:error, :not_found} ->
        {:ok, user} =
          Accounts.system_create(%{
            email: "importer@challenge.gov",
            first_name: "Importer",
            last_name: "User",
            role: "challenge_manager",
            terms_of_use: DateTime.truncate(DateTime.utc_now(), :second),
            privacy_guidelines: DateTime.truncate(DateTime.utc_now(), :second),
            status: "active"
          })

        user

      {:ok, user} ->
        user
    end
  end

  # Agency Helpers
  def match_agency(name, logo \\ nil) do
    if name == "" do
      nil
    else
      case Agencies.get_by_name(name) do
        {:ok, agency} ->
          generate_agency_id_map(agency)

        {:error, :not_found} ->
          fuzzy_match_agency(name, logo)
      end
    end
  end

  defp fuzzy_match_agency(name, logo) do
    agencies = Agencies.all_for_select()

    match =
      Enum.find(agencies, fn x ->
        String.jaro_distance(x.name, name) >= 0.9
      end)

    if match != nil do
      generate_agency_id_map(match)
    else
      create_new_agency(name, logo)
    end
  end

  defp create_new_agency(name, logo) when is_nil(logo) do
    {:ok, agency} =
      Agencies.create(:saved_to_file, %{
        name: "#{name}",
        created_on_import: true
      })

    generate_agency_id_map(agency)
  end

  defp create_new_agency(name, logo_url) do
    filename = Path.basename(logo_url)
    extension = Path.extname(filename)

    {:ok, tmp_file} = Stein.Storage.Temp.create(extname: extension)

    request = Finch.build(:get, "https://www.challenge.gov/assets/netlify-uploads/#{filename}")
    response = Finch.request(request, HTTPClient)

    # response =
    #   Finch.request(
    #     HTTPClient,
    #     :get,
    #     "https://www.challenge.gov/assets/netlify-uploads/#{filename}"
    #   )

    case response do
      {:ok, %{status: 200, body: body}} ->
        File.write!(tmp_file, body, [:binary])

        {:ok, agency} =
          Agencies.create(:saved_to_file, %{
            avatar: %{path: tmp_file},
            name: name,
            created_on_import: true
          })

        generate_agency_id_map(agency)

      _ ->
        {:ok, agency} = Agencies.create(:saved_to_file, %{name: name, created_on_import: true})
        generate_agency_id_map(agency)
    end
  end

  defp generate_agency_id_map(agency = %{parent_id: nil}) do
    %{
      "agency_id" => agency.id,
      "sub_agency_id" => nil
    }
  end

  defp generate_agency_id_map(agency = %{parent_id: parent_id}) do
    %{
      "agency_id" => parent_id,
      "sub_agency_id" => agency.id
    }
  end

  # Federal Partner Helpers
  def match_federal_partners(""), do: ""

  def match_federal_partners(partners) do
    partner_list = String.split(partners, ",")

    partner_list
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {x, id}, partners ->
      Map.put(partners, id, match_agency(String.trim(x)))
    end)
  end

  # Non Federal Partner Helpers
  def match_non_federal_partners(""), do: ""

  def match_non_federal_partners(partners) do
    partner_list = String.split(partners, ",")

    partner_list
    |> Stream.with_index()
    |> Enum.reduce(%{}, fn {partner, idx}, acc ->
      Map.put(acc, to_string(idx), %{"name" => String.trim(partner)})
    end)
  end

  # Prize Helper
  def sanitize_prize_amount(""), do: ""

  def sanitize_prize_amount(prize) do
    {number, _float} =
      prize
      |> String.replace(~r"(?=.*)\,(?=.*)", "")
      |> String.replace(~r"(?=.*)\$(?=.*)", "")
      |> Integer.parse()
      |> case do
        :error ->
          {0, 0}

        result ->
          result
      end

    number
  end

  # Custom URL Helper
  def parse_custom_url(permalink) do
    case Regex.named_captures(~r/\/challenge\/(?<link>.*)\//, permalink) do
      nil ->
        nil

      capture ->
        capture["link"]
    end
  end

  # Types Helper
  def scan_types(challenge_id, types, mappings \\ %{}) do
    types = format_types(types)

    scanned_types =
      Enum.flat_map(types, fn type ->
        if Enum.member?(Challenge.challenge_types(), type) do
          [type]
        else
          closest_match = find_closest_matching_type(type)
          verify_type_match(challenge_id, type, closest_match, mappings)
        end
      end)

    mappings = generate_type_mappings(mappings, types, scanned_types)

    # credo:disable-for-next-line
    IO.inspect(mappings)

    {scanned_types, mappings}
  end

  defp find_closest_matching_type(type) do
    Enum.max_by(Challenge.challenge_types(), fn challenge_type ->
      String.jaro_distance(challenge_type, type)
    end)
  end

  defp verify_type_match(challenge_id, type, closest_match, mappings) do
    score = String.jaro_distance(closest_match, type)

    existing_type_map = Map.get(mappings, type)

    if existing_type_map do
      [existing_type_map]
    else
      response =
        Mix.shell().yes?("""
        Does this look right?
        ID #{challenge_id}: #{type} -> #{closest_match} (#{score})
        """)

      if response do
        [closest_match]
      else
        pick_new_types()
      end
    end
  end

  defp pick_new_types() do
    response =
      """
      How many types should this be?
      """
      |> Mix.shell().prompt()
      |> String.replace("\n", "")
      |> String.to_integer()

    Enum.map(1..response, fn index ->
      pick_new_type(index)
    end)
  end

  defp pick_new_type(index) do
    available_types = Enum.with_index(Challenge.challenge_types())

    types_for_display =
      Enum.map(available_types, fn {type, index} ->
        "#{index}. #{type}\n"
      end)

    response =
      """
      Choose new type #{index}:
      #{types_for_display}
      """
      |> Mix.shell().prompt()
      |> String.replace("\n", "")
      |> String.to_integer()

    {result, _index} = Enum.at(available_types, response)

    result
  end

  def generate_type_mappings(mappings, types, scanned_types) do
    if length(types) == length(scanned_types) do
      types
      |> Enum.with_index()
      |> Enum.reduce(mappings, fn {type, index}, mappings ->
        Map.put_new(mappings, type, Enum.at(scanned_types, index))
      end)
    else
      mappings
    end
  end

  def format_types(""), do: []

  def format_types(nil), do: []

  def format_types(types) when is_bitstring(types) do
    if String.contains?(types, ";") do
      types
      |> String.split(";")
      |> Enum.map(fn x -> String.trim(x) end)
    else
      [types]
    end
  end

  def format_types(types) do
    types
  end

  # Logo Helpers
  def prep_logo(""), do: ""

  def prep_logo(logo_url) do
    filename = Path.basename(logo_url)
    extension = Path.extname(filename)

    {:ok, tmp_file} = Stein.Storage.Temp.create(extname: extension)

    request = Finch.build(:get, logo_url)

    case Finch.request(request, HTTPClient) do
      {:ok, %{status: 200, body: body}} ->
        File.write!(tmp_file, body, [:binary])

        %{
          filename: filename,
          path: tmp_file
        }

      {:ok, %{status: 404}} ->
        ""
    end
  end

  # Date Helpers
  def format_date(date, fiscal_year, id) do
    approximate_date(sanitize_date(date), fiscal_year, id)
  end

  defp approximate_date(date, fiscal_year, id) when is_nil(date) or date == "" do
    case id do
      "start" ->
        year = get_earliest_fiscal_year(fiscal_year) - 1

        {{year, 10, 1}, {0, 0, 0}}
        |> Timex.to_datetime()
        |> Timex.format!("{ISO:Extended}")

      "end" ->
        year = get_latest_fiscal_year(fiscal_year)

        {{year, 9, 30}, {0, 0, 0}}
        |> Timex.to_datetime()
        |> Timex.format!("{ISO:Extended}")
    end
  end

  defp approximate_date(date, _fiscal_year, _id), do: Timex.format!(date, "{ISO:Extended}")

  defp get_earliest_fiscal_year(fiscal_years) do
    fiscal_years
    |> parse_fiscal_year
    |> Enum.at(0)
  end

  defp get_latest_fiscal_year(fiscal_years) do
    fiscal_years
    |> parse_fiscal_year
    |> Enum.at(-1)
  end

  defp parse_fiscal_year(fiscal_years) when not is_nil(fiscal_years) and fiscal_years != "" do
    fiscal_years
    |> String.split(",")
    |> Enum.map(fn fiscal_year ->
      get_year_from_fiscal_year(fiscal_year)
    end)
  end

  defp parse_fiscal_year(_fiscal_years), do: [2005]

  # Converts fiscal year to a year in 2000 for this import
  defp get_year_from_fiscal_year(fiscal_year)
       when not is_nil(fiscal_year) and fiscal_year != "" do
    fiscal_year
    |> String.trim()
    |> String.replace("FY", "20")
    |> String.to_integer()
  end

  # Sets missing fiscal years to 2005
  defp get_year_from_fiscal_year(_fiscal_year), do: 2005

  defp sanitize_date(""), do: ""

  defp sanitize_date(date) do
    # replace all spaces with single space and rm "."
    formatted_date =
      date
      |> String.replace(~r/\s+/, " ")
      |> String.replace(~r/\.+/, "")

    utc_datetime =
      Enum.find_value(@date_formats, fn format ->
        case Timex.parse(formatted_date, format) do
          {:ok, parsed_time} ->
            {:ok, eastern_datetime} = DateTime.from_naive(parsed_time, "America/New_York")
            {:ok, utc_datetime} = DateTime.from_naive(eastern_datetime, "Etc/UTC")
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

  def prep_import_output_file(filename) do
    File.mkdir_p("tmp/import_output")
    {:ok, file} = File.open("tmp/import_output/#{filename}", [:write])

    headers = [
      "Challenge ID",
      "Challenge Title",
      "Challenge Types",
      "Prize Total"
    ]

    headers = Enum.join(headers, ",")
    IO.binwrite(file, headers <> "\n")

    file
  end

  def create_import_output_file(file, json) do
    values = [
      json["challenge-id"],
      json["challenge-title"],
      json["type-of-challenge"],
      json["total-prize-offered-cash"]
    ]

    values = Enum.join(values, ",")

    IO.binwrite(file, values <> "\n")
  end
end
