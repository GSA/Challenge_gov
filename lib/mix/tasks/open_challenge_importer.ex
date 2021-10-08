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

    output_file = ImportHelper.prep_import_output_file("feed-open.csv")

    import_user_id = ImportHelper.import_user().id

    case Jason.decode(result) do
      {:ok, json} ->
        json["_challenge"]
        # credo:disable-for-next-line
        |> Enum.reduce(%{}, fn challenge, mappings ->
          ImportHelper.create_import_output_file(output_file, challenge)
          create_challenge(challenge, import_user_id, mappings)
        end)

      {:error, error} ->
        error
    end

    File.close(output_file)
  end

  @doc """
  Create a challenge based off mapped fields
  """
  def create_challenge(json, import_user_id, mappings) do
    {scanned_types, mappings} =
      ImportHelper.scan_types(json["challenge-id"], json["type-of-challenge"], mappings)

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
        "agency_id" =>
          ImportHelper.match_agency(json["agency"], json["agency-logo"])["agency_id"],
        "sub_agency_id" =>
          ImportHelper.match_agency(json["agency"], json["agency-logo"])["sub_agency_id"],
        "tagline" => json["tagline"],
        "legal_authority" => json["legal-authority"],
        "fiscal_year" => json["fiscal-year"],
        "primary_type" => Enum.at(scanned_types, 0),
        "types" => Enum.slice(scanned_types, 1..3),
        "other_type" => Enum.at(scanned_types, 4),
        "prize_total" => ImportHelper.sanitize_prize_amount(json["total-prize-offered-cash"]),
        "federal_partners" =>
          ImportHelper.match_federal_partners(json["partner-agencies-federal"]),
        "non_federal_partners" =>
          ImportHelper.match_non_federal_partners(json["partners-non-federal"]),
        "challenge_manager" => json["challenge-manager"],
        "challenge_manager_email" => json["challenge-manager-email"],
        "poc_email" => json["point-of-contact"],
        "description" => json["description"],
        "prize_description" => json["prizes"],
        "rules" => json["rules"],
        "is_multi_phase" => false,
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
        error
    end

    mappings
  end
end
