defmodule Mix.Tasks.OpenChallengeImporter do
  @moduledoc """
  Importer for archived challenges
  """
  use Mix.Task

  alias ChallengeGov.Challenges
  alias Mix.Tasks.ImportHelper

  def run(_file) do
    Mix.Task.run("app.start")
    Logger.configure(level: :error)

    result = File.read!("lib/mix/tasks/sample_data/feed-open.json")

    import_user_id = ImportHelper.import_user().id

    initial_mappings = %{
      "agencies" => %{},
      "types" => %{}
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
        "status" => "published",
        "custom_url" => ImportHelper.parse_custom_url(json["permalink"]),
        "external_url" => json["external-url"],
        "logo" => ImportHelper.prep_logo(json["card-image"]),
        "upload_logo" => ImportHelper.upload_logo_boolean(json["card-image"]),
        "auto_publish_date" => ImportHelper.auto_publish_date(),
        "agency_id" => matched_agencies["agency_id"],
        "sub_agency_id" => matched_agencies["sub_agency_id"],
        "tagline" => json["tagline"],
        "legal_authority" => json["legal-authority"],
        "fiscal_year" => json["fiscal-year"],
        "primary_type" => Enum.at(scanned_types, 0),
        "types" => Enum.slice(scanned_types, 1..3),
        "other_type" => Enum.at(scanned_types, 4),
        "prize_type" => ImportHelper.prize_type_boolean(json["total-prize-offered-cash"], ""),
        "prize_total" => ImportHelper.sanitize_prize_amount(json["total-prize-offered-cash"]),
        "federal_partners" => matched_partner_agencies,
        "non_federal_partners" =>
          ImportHelper.match_non_federal_partners(json["partners-non-federal"]),
        "challenge_manager" => json["challenge-manager"],
        "challenge_manager_email" => json["challenge-manager-email"],
        "poc_email" => json["point-of-contact"],
        "description" => json["description"],
        "prize_description" => json["prizes"],
        "rules" => json["rules"],
        "is_multi_phase" => false,
        "terms_equal_rules" => ImportHelper.terms_equal_rules_boolean(),
        "phases" => %{
          "0" => %{
            "open_to_submissions" => true,
            "start_date" =>
              ImportHelper.format_date(json["submission-start"], json["fiscal-year"], "start"),
            "end_date" =>
              ImportHelper.format_date(json["submission-end"], json["fiscal-year"], "end"),
            "judging_criteria" => json["judging"],
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
        Mix.shell().prompt("Error recorded")
        error
    end

    mappings
  end
end
