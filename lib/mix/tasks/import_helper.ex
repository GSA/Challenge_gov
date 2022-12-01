require Logger

defmodule Mix.Tasks.ImportHelper do
  @moduledoc """
  Helper for archived challenge importers
  """

  alias ChallengeGov.Accounts
  alias ChallengeGov.Agencies
  alias ChallengeGov.Challenges.Challenge
  alias ChallengeGov.HTTPClient
  alias ChallengeGov.Repo
  alias Mix.Tasks.Mappings

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
  def match_agency(name, _logo \\ nil, challenge_id \\ nil, mappings \\ %{}) do
    name = String.trim(name)

    cond do
      name == "" ->
        {nil, mappings}

      Map.get(Mappings.challenge_id_agency_map(), challenge_id) ->
        mapped_agency = Map.get(Mappings.challenge_id_agency_map(), challenge_id)
        # credo:disable-for-next-line
        IO.inspect(mapped_agency, label: "CHALLENGE ID MAP")

        # {matched_agency, mappings} = find_or_create_agency_match(agency_name, agencies, mappings, parent_agency \\ nil)

        {matched_parent_agency, matched_component_agency, mappings} =
          find_agency_matches(mapped_agency["parent"], mapped_agency["component"], mappings)

        matched_component_agency_id =
          if matched_component_agency, do: matched_component_agency.id, else: nil

        {
          %{
            "agency_id" => matched_parent_agency.id,
            "sub_agency_id" => matched_component_agency_id
          },
          mappings
        }

      is_map(Map.get(mappings, name)) ->
        mapped_agency = Map.get(mappings, name)
        # credo:disable-for-next-line
        IO.inspect(mapped_agency, label: "IMMEDIATE MATCH")

        if mapped_agency["parent"] do
          # {matched_agency, mappings} = find_or_create_agency_match(agency_name, agencies, mappings, parent_agency \\ nil)

          {matched_parent_agency, matched_component_agency, mappings} =
            find_agency_matches(mapped_agency["parent"], mapped_agency["component"], mappings)

          matched_component_agency_id =
            if matched_component_agency, do: matched_component_agency.id, else: nil

          {
            %{
              "agency_id" => matched_parent_agency.id,
              "sub_agency_id" => matched_component_agency_id
            },
            mappings
          }
        else
          {
            %{
              "agency_id" => nil,
              "sub_agency_id" => nil
            },
            mappings
          }
        end

      true ->
        # credo:disable-for-next-line
        IO.inspect("Matching agency for challenge #{challenge_id}")
        # credo:disable-for-next-line
        IO.inspect(name, label: "Original agency name")
        {parent_agency_name, component_agency_name} = check_for_component_agencies(name)

        {matched_parent_agency, matched_component_agency, mappings} =
          find_agency_matches(parent_agency_name, component_agency_name, mappings)

        matched_component_agency_id =
          if matched_component_agency, do: matched_component_agency.id, else: nil

        {
          %{
            "agency_id" => matched_parent_agency.id,
            "sub_agency_id" => matched_component_agency_id
          },
          mappings
        }
    end
  end

  defp check_for_component_agencies(agency_name) do
    split_agencies =
      agency_name
      |> String.split("-")
      |> Enum.map(fn name -> String.trim(name) end)
      |> Enum.reject(fn name -> name == "" end)

    parent_agency = Enum.at(split_agencies, 0)
    component_agency = Enum.at(split_agencies, 1)

    {parent_agency, component_agency}
  end

  defp find_agency_matches(parent_agency_name, component_agency_name, mappings) do
    agencies = Agencies.all_for_select()

    {matched_parent_agency, mappings} =
      find_or_create_agency_match(parent_agency_name, agencies, mappings)

    {matched_component_agency, mappings} =
      if component_agency_name do
        matched_parent_agency = Repo.preload(matched_parent_agency, [:sub_agencies])
        component_agencies = matched_parent_agency.sub_agencies

        find_or_create_agency_match(
          component_agency_name,
          component_agencies,
          mappings,
          matched_parent_agency
        )
      else
        {nil, mappings}
      end

    {matched_parent_agency, matched_component_agency, mappings}
  end

  defp find_or_create_agency_match(agency_name, agencies, mappings, parent_agency \\ nil) do
    if Enum.empty?(agencies) do
      create_agency_match(agency_name, mappings, parent_agency)
    else
      agency_name = String.trim(agency_name)

      matched_agency =
        Enum.max_by(agencies, fn agency ->
          String.jaro_distance(agency.name, agency_name)
        end)

      score = String.jaro_distance(agency_name, String.trim(matched_agency.name))
      map_match = Map.get(mappings, agency_name)

      cond do
        score == 1 ->
          # credo:disable-for-next-line
          IO.inspect("Exact match: #{agency_name} -> #{matched_agency.name}")
          {matched_agency, mappings}

        is_map(map_match) ->
          # credo:disable-for-next-line
          agency_map_match =
            if parent_agency, do: map_match["component"], else: map_match["parent"]

          # credo:disable-for-next-line
          IO.inspect("Mapping match: #{agency_name} -> #{agency_map_match}")
          get_agency_map_match(agency_map_match, mappings, parent_agency)

        map_match ->
          # credo:disable-for-next-line
          IO.inspect("Mapping match: #{agency_name} -> #{map_match}")
          get_agency_map_match(map_match, mappings, parent_agency)

        false ->
          mappings = Map.put(mappings, agency_name, matched_agency.name)
          {matched_agency, mappings}

        true ->
          create_agency_match(agency_name, mappings, parent_agency)
      end
    end
  end

  defp get_agency_map_match(agency_name, mappings, parent_agency) do
    if parent_agency do
      matched_agency =
        Enum.find(parent_agency.sub_agencies, fn sub_agency -> sub_agency.name == agency_name end)

      if matched_agency do
        {matched_agency, mappings}
      else
        create_agency_match(agency_name, mappings, parent_agency)
      end
    else
      {:ok, matched_agency} = Agencies.get_by_name(agency_name)
      {matched_agency, mappings}
    end
  end

  defp create_agency_match(agency_name, mappings, parent_agency) do
    acronym = generate_agency_acronym(agency_name)

    agency_params = %{
      name: agency_name,
      acronym: acronym,
      created_on_import: true
    }

    agency_params =
      if parent_agency do
        Map.merge(agency_params, %{parent_id: parent_agency.id})
      else
        agency_params
      end

    {:ok, created_agency} = Agencies.create(:saved_to_file, agency_params)

    # credo:disable-for-next-line
    IO.inspect("No match. Creating agency: #{created_agency.name} (#{created_agency.acronym})")
    mappings = Map.put(mappings, agency_name, created_agency.name)
    {created_agency, mappings}
  end

  defp generate_agency_acronym(name) do
    name
    |> String.split(" ")
    |> Enum.map_join(fn word ->
      word
      |> String.upcase()
      |> String.first()
    end)
  end

  # Federal Partner Helpers
  def match_federal_partners(_partners, challenge_id \\ nil, mappings \\ %{})

  def match_federal_partners("", _challenge_id, mappings), do: {"", mappings}

  def match_federal_partners(partners, challenge_id, mappings) do
    partner_list =
      if Map.get(Mappings.challenge_id_federal_partner_map(), challenge_id) do
        Map.get(Mappings.challenge_id_federal_partner_map(), challenge_id)
      else
        String.split(partners, ",")
      end

    initial_acc = %{
      "mappings" => mappings,
      "partners" => %{}
    }

    matched_partner_acc =
      partner_list
      |> Enum.with_index()
      |> Enum.reduce(initial_acc, fn {x, id}, acc ->
        mappings = Map.get(acc, "mappings")
        partners = Map.get(acc, "partners")

        {matched_agencies, mappings} = match_agency(String.trim(x), nil, challenge_id, mappings)

        partners = Map.put(partners, id, matched_agencies)

        acc
        |> Map.replace("mappings", mappings)
        |> Map.replace("partners", partners)
      end)

    mappings = Map.get(matched_partner_acc, "mappings")

    partners =
      matched_partner_acc
      |> Map.get("partners")
      |> Map.values()
      |> Enum.uniq()
      |> Enum.with_index()
      |> Map.new(fn {partner, index} ->
        {index, partner}
      end)

    # credo:disable-for-next-line
    IO.inspect(partners, label: "PARTNERS LIST")

    {partners, mappings}
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

        {dollars, float} ->
          {dollars * 100, float}
      end

    number
  end

  def prize_type_boolean(prize, non_monetary_prize) do
    case {prize, non_monetary_prize} do
      {"", non_monetary_prize} when non_monetary_prize != "" -> "non_monetary"
      {prize, ""} when prize != "" -> "monetary"
      {_, _} -> "both"
    end
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

    cond do
      is_list(existing_type_map) ->
        existing_type_map

      existing_type_map ->
        [existing_type_map]

      true ->
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

  def upload_logo_boolean(""), do: false
  def upload_logo_boolean(_logo_url), do: true

  def auto_publish_date(), do: DateTime.utc_now()

  def terms_equal_rules_boolean(), do: true

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
            {:ok, utc_datetime} = DateTime.shift_zone(eastern_datetime, "Etc/UTC")
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
