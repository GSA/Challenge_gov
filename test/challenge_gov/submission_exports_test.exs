defmodule ChallengeGov.SubmissionExportsTest do
  use ChallengeGov.DataCase

  alias ChallengeGov.SubmissionExports
  alias ChallengeGov.TestHelpers.AccountHelpers
  alias ChallengeGov.TestHelpers.ChallengeHelpers

  describe "exporting submissions" do
    test "success: all as zip" do
      user = AccountHelpers.create_user()

      challenge =
        ChallengeHelpers.create_archived_multi_phase_challenge(user, %{user_id: user.id})

      phase_ids =
        Enum.map(challenge.phases, fn phase ->
          to_string(phase.id)
        end)

      params = %{
        "phase_ids" => phase_ids,
        "judging_status" => "all",
        "format" => ".zip"
      }

      {:ok, submission_export} = SubmissionExports.create(params, challenge)
      {:ok, _submission_export} = SubmissionExports.trigger_export(submission_export)
    end
  end
end
