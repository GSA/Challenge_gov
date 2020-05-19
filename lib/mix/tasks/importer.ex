defmodule Mix.Tasks.ClosedChallengeImporter do
  @moduledoc """
  Importer for archived challenges
  """
  use Mix.Task

  defmodule Parse do
    def run(string) do
      parse(Jason.decode(string))
    end
    def parse({:ok, map}), do: {:ok, map}
    def parse({:error, error}) do
      case backtrack(error.data, error.position) do
        {:ok, position} ->
          {first, "\"" <> second} = String.split_at(error.data, position)
          parse(Jason.decode(first <> "\\\"" <> second))
        :error ->
          {:error, error}
      end
    end
    def backtrack(_string, 0), do: :error
    def backtrack(string, position) do
      case String.at(string, position - 1) == "\"" do
        true ->
          {:ok, position - 1}
        false ->
          backtrack(string, position - 1)
      end
    end
  end

  def run(_file) do
    Mix.Task.run("app.start")

    # should be starting with parsed file from Eric:
      # Parse.run(original_feed)

    # Do we need to read and decode again? (read, to get it, decode to make sure it's valid)
    case File.read!("lib/mix/tasks/sample_data/feed-closed.json") do
      {:ok, binary} ->
        case Jason.decode(binary) do
          {:ok, challenge} ->
            # create archived challenge
            create_challenge(challenge)

          {:error, error} ->
            # then what?
            IO.inspect error
        end

      {:error, error} ->
        IO.inspect error
    end
  end

  def create_challenge(challenge) do
    
  end
#
# # unused:
#   # challenge-id
#   # partner-agencies-federal
#   # challenge_status
#   # partners-non-federal
#
#       {ok, _challenge} =
#         Challenges.create(%{
#           "user_id" => ,
#           "agency_id" => ,
#           "status" => "archived", # or challenge_status?
#           "challenge_manager" => challenge-manager,
#           "challenge_manager_email" => challenge-manager-email, #both?
#           "poc_email" => ,
#           "agency_name" => agency, # ?
#           "title" => challenge-title,
#           "custom_url" => ,
#           "external_url" => external-url,
#           "tagline" => tagline,
#           "description" => description,
#           "brief_description" => ,
#           "how_to_enter" => how-to-enter,
#           "fiscal_year" => fiscal-year,
#           "start_date" => submission-start,
#           "end_date" => submission-end,
#           "multi_phase" => ,
#           "number_of_phases" => ,
#           "phase_descriptions" => ,
#           "phase_dates" => ,
#           "judging_criteria" => ,
#           "prize_total" => total-prize-offered-cash,
#           "non_monetary_prizes" => non-monetary-incentives-awarded,
#           "prize_description" => ,
#           "eligibility_requirements" => ,
#           "rules" => rules,
#           "terms_and_conditions" => ,
#           "legal_authority" => legal-authority,
#           "faq" => ,
#           "winner_information" => ,
#           "types" => type-of-challenge,
#           "auto_publish_date" =>
#         })
#     end)
  end

  # defp parseJudgingCriteria() do
  #   # map through and check for empty strings or if data and concat
  #   criteria = [
  #     judging-criteria-0,
  #     judging-criteria-percentage-0,
  #     judging-criteria-description-0,
  #     judging-criteria-1,
  #     judging-criteria-percentage-1,
  #     judging-criteria-description-1,
  #     judging-criteria-2,
  #     judging-criteria-percentage-2,
  #     judging-criteria-description-2,
  #     judging-criteria-3,
  #     judging-criteria-percentage-3,
  #     judging-criteria-description-3,
  #     judging-criteria-4,
  #     judging-criteria-percentage-4,
  #     judging-criteria-description-4,
  #     judging-criteria-5,
  #     judging-criteria-percentage-5,
  #     judging-criteria-description-5,
  #     judging-criteria-6,
  #     judging-criteria-percentage-6,
  #     judging-criteria-description-6,
  #     judging-criteria-7,
  #     judging-criteria-percentage-7,
  #     judging-criteria-description-7,
  #     judging-criteria-8,
  #     judging-criteria-percentage-8,
  #     judging-criteria-description-8,
  #     judging-criteria-9,
  #     judging-criteria-percentage-9,
  #     judging-criteria-description-9
  #   ]
  # end

  # defp parsePrizeDescription() do
  # end
  #
  # defp parseWinnerInformation do
  # end
end
