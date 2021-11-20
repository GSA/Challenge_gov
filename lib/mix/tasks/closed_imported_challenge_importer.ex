defmodule Mix.Tasks.ClosedImportedChallengeImporter do
  @moduledoc """
  Importer for archived challenges
  """
  use Mix.Task

  alias ChallengeGov.Challenges
  alias Mix.Tasks.ImportHelper
  alias Mix.Tasks.Mappings

  def run(_file) do
    Mix.Task.run("app.start")
    Logger.configure(level: :error)

    result = File.read!("lib/mix/tasks/sample_data/feed-closed-imported.json")

    import_user_id = ImportHelper.import_user().id

    initial_mappings = %{
      "agencies" => Mappings.agency_map(),
      "types" => Mappings.type_map()
    }

    case Jason.decode(result) do
      {:ok, json} ->
        json["_challenge"]
        # credo:disable-for-next-line
        |> Enum.reduce(initial_mappings, fn challenge, mappings ->
          create_challenge(challenge, import_user_id, mappings)
        end)

      {:error, error} ->
        error
    end
  end

  @doc """
  Create a challenge based off mapped fields
  """
  def create_challenge(json, import_user_id, mappings) do
    # credo:disable-for-next-line
    IO.inspect("Agency matching")

    {matched_agencies, agency_mappings} =
      ImportHelper.match_agency(
        json["agency"],
        json["agency-logo"],
        json["challenge-id"],
        mappings["agencies"]
      )

    mappings = Map.put(mappings, "agencies", agency_mappings)

    # credo:disable-for-next-line
    IO.inspect("Federal partner matching")

    {matched_partner_agencies, agency_mappings} =
      ImportHelper.match_federal_partners(
        json["partner-agencies-federal"],
        json["challenge-id"],
        mappings["agencies"]
      )

    mappings = Map.put(mappings, "agencies", agency_mappings)

    # credo:disable-for-next-line
    IO.inspect("Type matching")

    {scanned_types, type_mappings} =
      ImportHelper.scan_types(json["challenge-id"], json["type-of-challenge"], mappings["types"])

    mappings = Map.put(mappings, "types", type_mappings)

    # credo:disable-for-next-line
    IO.inspect(mappings, label: "All Mappings")

    result =
      Challenges.import_create(%{
        "id" => json["challenge-id"],
        "imported" => true,
        "user_id" => import_user_id,
        "title" => json["challenge-title"],
        "custom_url" => ImportHelper.parse_custom_url(json["permalink"]),
        "external_url" => json["external-url"],
        "tagline" => json["tagline"],
        "upload_logo" => ImportHelper.upload_logo_boolean(""),
        "auto_publish_date" => ImportHelper.auto_publish_date(),
        "legal_authority" => json["legal-authority"],
        "primary_type" => Enum.at(scanned_types, 0),
        "types" => Enum.slice(scanned_types, 1..3),
        "other_type" => Enum.at(scanned_types, 4),
        "prize_type" =>
          ImportHelper.prize_type_boolean(
            json["total-prize-offered-cash"],
            json["non-monetary-incentives-awarded"]
          ),
        "prize_total" => ImportHelper.sanitize_prize_amount(json["total-prize-offered-cash"]),
        "non_monetary_prizes" => json["non-monetary-incentives-awarded"],
        "prize_description" => format_prize_description(json),
        "status" => "published",
        "agency_id" => matched_agencies["agency_id"],
        "sub_agency_id" => matched_agencies["sub_agency_id"],
        "federal_partners" => matched_partner_agencies,
        "non_federal_partners" =>
          ImportHelper.match_non_federal_partners(json["partners-non-federal"]),
        "challenge_manager_email" => find_manager_email(json),
        "challenge_manager" => json["challenge-manager"],
        "fiscal_year" => json["fiscal-year"],
        "description" => json["description"],
        "rules" => json["rules"],
        "winner_information" => format_winner_information(json),
        "is_multi_phase" => false,
        "terms_equal_rules" => ImportHelper.terms_equal_rules_boolean(),
        "phases" => %{
          "0" => %{
            "open_to_submissions" => true,
            "start_date" =>
              ImportHelper.format_date(json["submission-start"], json["fiscal-year"], "start"),
            "end_date" =>
              ImportHelper.format_date(json["submission-end"], json["fiscal-year"], "end"),
            "judging_criteria" => format_judging_criteria(json),
            "how_to_enter" => json["how-to-enter"]
          }
        }
      })

    case result do
      {:ok, result} ->
        Challenges.set_sub_status(result)
        result

      {:error, error} ->
        # credo:disable-for-next-line
        IO.inspect(error)
        # Mix.shell().prompt("Error recorded")
        error
    end

    mappings
  end

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
end
