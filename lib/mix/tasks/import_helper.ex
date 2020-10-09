defmodule Mix.Tasks.ImportHelper do
  @moduledoc """
  Helper for archived challenge importers
  """

  alias ChallengeGov.Accounts
  alias ChallengeGov.Agencies
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

    response =
      Finch.request(
        HTTPClient,
        :get,
        "https://www.challenge.gov/assets/netlify-uploads/#{filename}"
      )

    case response do
      {:ok, %{status: 200, body: body}} ->
        File.write!(tmp_file, body, [:binary])

        {:ok, agency} =
          Agencies.create(:saved_to_file, %{
            avatar: %{path: tmp_file},
            name: name,
            created_on_import: true
          })

        agency.id

      _ ->
        {:ok, agency} = Agencies.create(:saved_to_file, %{name: name, created_on_import: true})
        agency.id
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

    number
  end

  # Types Helper
  def format_types(""), do: ""

  def format_types(types) do
    types
    |> String.split(";")
    |> Enum.map(fn x -> String.trim(x) end)
  end

  # Logo Helpers
  def prep_logo(""), do: ""

  def prep_logo(logo_url) do
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

  # Date Helpers
  def format_date(date, fiscal_year, id) do
    approximate_date(sanitize_date(date), fiscal_year, id)
  end

  defp approximate_date(date, fiscal_year, id) when is_nil(date) or date == "" do
    case id do
      "start" ->
        year = get_earliest_fiscal_year(fiscal_year) - 1
        Timex.to_datetime({{year, 10, 1}, {0, 0, 0}})

      "end" ->
        year = get_latest_fiscal_year(fiscal_year)
        Timex.to_datetime({{year, 9, 30}, {0, 0, 0}})
    end
  end

  defp approximate_date(date, _fiscal_year, _id), do: date

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
end
