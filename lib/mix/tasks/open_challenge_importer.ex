defmodule Mix.Tasks.OpenChallengeImporter do
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
  alias ChallengeGov.HTTPClient

  def run(_file) do
    Mix.Task.run("app.start")

    result = File.read!("lib/mix/tasks/sample_data/feed-open-parsed.json")

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
        "status" => "published",
        "external_url" => json["external-url"],
        "logo" => prep_logo(json["card-image"]),
        "agency_id" => match_agency(json["agency"], json["agency-logo"]),
        "tagline" => json["tagline"],
        "legal_authority" => json["legal-authority"],
        "fiscal_year" => json["fiscal-year"],
        "types" => format_types(json["type-of-challenge"]),
        "prize_total" => sanitize_prize_amount(json["total-prize-offered-cash"]),
        "federal_partners" => match_federal_partners(json["partner-agencies-federal"]),
        "non_federal_partners" => match_non_federal_partners(json["partners-non-federal"]),
        "challenge_manager" => json["challenge-manager"],
        "challenge_manager_email" => json["challenge-manager-email"],
        "poc_email" => json["point-of-contact"],
        "start_date" => sanitize_date(json["submission-start"]),
        "end_date" => sanitize_date(json["submission-end"]),
        "description" => json["description"],
        "prize_description" => json["prizes"],
        "rules" => json["rules"],
        "judging_criteria" => json["judging"],
        "how_to_enter" => json["how-to-enter"]
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

    if match != nil do
      match.id
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

        {:ok, agency} = Agencies.create(:saved_to_file, %{avatar: %{path: tmp_file}, name: name, created_on_import: true})
        agency.id

      _ ->
        {:ok, agency} = Agencies.create(:saved_to_file, %{name: name, created_on_import: true})
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
    |> String.split(~r{(?=[A-Z]+)}, trim: true)
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
