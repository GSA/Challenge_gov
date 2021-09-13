defmodule Mix.Tasks.ClosedImportedChallengeImporter do
  @moduledoc """
  Importer for archived challenges
  """
  use Mix.Task

  alias ChallengeGov.Challenges
  alias Mix.Tasks.ImportHelper

  def run(_file) do
    Mix.Task.run("app.start")
    Logger.configure(level: :error)

    result = File.read!("lib/mix/tasks/sample_data/feed-closed-imported.json")

    output_file = ImportHelper.prep_import_output_file("feed-closed-imported.csv")

    import_user_id = ImportHelper.import_user().id

    case Jason.decode(result) do
      {:ok, json} ->
        json["_challenge"]
        |> Enum.each(fn challenge ->
          ImportHelper.create_import_output_file(output_file, challenge)
          create_challenge(challenge, import_user_id)
        end)

      {:error, error} ->
        error
    end

    File.close(output_file)
  end

  @doc """
  Create a challenge based off mapped fields
  """
  def create_challenge(json, import_user_id) do
    scanned_types = ImportHelper.scan_types(json["challenge-id"], json["type-of-challenge"])

    result =
      Challenges.import_create(%{
        "id" => json["challenge-id"],
        "imported" => true,
        "user_id" => import_user_id,
        "title" => json["challenge-title"],
        "custom_url" => ImportHelper.parse_custom_url(json["permalink"]),
        "external_url" => json["external-url"],
        "tagline" => json["tagline"],
        "legal_authority" => json["legal-authority"],
        "primary_type" => Enum.at(scanned_types, 0),
        "types" => Enum.slice(scanned_types, 1..3),
        "other_type" => Enum.at(scanned_types, 4),
        "prize_total" => ImportHelper.sanitize_prize_amount(json["total-prize-offered-cash"]),
        "non_monetary_prizes" => json["non-monetary-incentives-awarded"],
        "prize_description" => format_prize_description(json),
        "status" => "published",
        "agency_id" => ImportHelper.match_agency(json["agency"])["agency_id"],
        "sub_agency_id" => ImportHelper.match_agency(json["agency"])["sub_agency_id"],
        "federal_partners" =>
          ImportHelper.match_federal_partners(json["partner-agencies-federal"]),
        "non_federal_partners" =>
          ImportHelper.match_non_federal_partners(json["partners-non-federal"]),
        "challenge_manager_email" => find_manager_email(json),
        "challenge_manager" => json["challenge-manager"],
        "fiscal_year" => json["fiscal-year"],
        "description" => json["description"],
        "rules" => json["rules"],
        "winner_information" => format_winner_information(json),
        "is_multi_phase" => false,
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
        error
    end
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
