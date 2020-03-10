defmodule Mix.Tasks.Importer do
  @moduledoc """
  Importer for archived challenges
  """
  use Mix.Task


  def run(_file) do
    Mix.Task.run("app.start")

    case File.read("lib/mix/tasks/sample_data/type_one.json") do
      {:ok, binary} ->
        IO.inspect binary
      # {ok, binary} = File.read(file)
        parsed_data = Jason.decode(binary)
        IO.puts("{{{{{{heree}}}}}}")
        IO.inspect parsed_data

      {:error, error} ->
      IO.inspect error
    end

# below in the right format? (with dashes?)
#     Enum.map(parsed_data, fn challenge ->
#       [
#         challenge-id,
#         challenge-title,
#         permalink,
#         external-url,
#         tagline,
#         legal-authority,
#         type-of-challenge,
#         total-prize-offered-cash,
#         non-monetary-incentives-awarded,
#         challenge_status,
#         agency,
#         partner-agencies-federal,
#         partners-non-federal,
#         challenge-manager-email,
#         challenge-manager,
#         challenge-manager-email, # repeated
#         submission-start,
#         submission-end,
#         fiscal-year,
#         description,
#         how-to-enter,
#         rules,
#         judging-criteria-0,
#         judging-criteria-percentage-0,
#         judging-criteria-description-0,
#         judging-criteria-1,
#         judging-criteria-percentage-1,
#         judging-criteria-description-1,
#         judging-criteria-2,
#         judging-criteria-percentage-2,
#         judging-criteria-description-2,
#         judging-criteria-3,
#         judging-criteria-percentage-3,
#         judging-criteria-description-3,
#         judging-criteria-4,
#         judging-criteria-percentage-4,
#         judging-criteria-description-4,
#         judging-criteria-5,
#         judging-criteria-percentage-5,
#         judging-criteria-description-5,
#         judging-criteria-6,
#         judging-criteria-percentage-6,
#         judging-criteria-description-6,
#         judging-criteria-7,
#         judging-criteria-percentage-7,
#         judging-criteria-description-7,
#         judging-criteria-8,
#         judging-criteria-percentage-8,
#         judging-criteria-description-8,
#         judging-criteria-9,
#         judging-criteria-percentage-9,
#         judging-criteria-description-9,
#         prize-name-0,
#         prize-cash-amount-0,
#         prize-description-0,
#         prize-name-1,
#         prize-cash-amount-1,
#         prize-description-1,
#         prize-name-2,
#         prize-cash-amount-2,
#         prize-description-2,
#         prize-name-3,
#         prize-cash-amount-3,
#         prize-description-3,
#         prize-name-4,
#         prize-cash-amount-4,
#         prize-description-4,
#         prize-name-5,
#         prize-cash-amount-5,
#         prize-description-5,
#         prize-name-6,
#         prize-cash-amount-6,
#         prize-description-6,
#         prize-name-7,
#         prize-cash-amount-7,
#         prize-description-7,
#         prize-name-8,
#         prize-cash-amount-8,
#         prize-description-8,
#         prize-name-9,
#         prize-cash-amount-9,
#         prize-description-9,
#         winner-name-0,
#         winner-solution-title-0,
#         winner-solution-link-0,
#         winner-name-1,
#         winner-solution-title-1,
#         winner-solution-link-1,
#         winner-name-2,
#         winner-solution-title-2,
#         winner-solution-link-2,
#         winner-name-3,
#         winner-solution-title-3,
#         winner-solution-link-3,
#         winner-name-4,
#         winner-solution-title-4,
#         winner-solution-link-4,
#         winner-name-5,
#         winner-solution-title-5,
#         winner-solution-link-5,
#         winner-name-6,
#         winner-solution-title-6,
#         winner-solution-link-6,
#         winner-name-7,
#         winner-solution-title-7,
#         winner-solution-link-7,
#         winner-name-8,
#         winner-solution-title-8,
#         winner-solution-link-8,
#         winner-name-9,
#         winner-solution-title-9,
#         winner-solution-link-9,
#       ] = challenge
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
  #   # map through and check for empty strings or if data and concat
  # end

  # defp parsePrizeDescription() do
  # end
  #
  # defp parseWinnerInformation do
  # end
end
