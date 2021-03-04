defmodule ChallengeGov.PhasesTest do
  use ChallengeGov.DataCase

  alias ChallengeGov.Phases
  alias ChallengeGov.TestHelpers.AccountHelpers
  alias ChallengeGov.TestHelpers.ChallengeHelpers

  describe "retrieving phases for a challenge" do
    test "success: single phase" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})
      _challenge_2 = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})

      assert length(Phases.all(filter: %{"challenge_id" => challenge.id})) === 1
    end

    test "success: multiple phases" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_multi_phase_challenge(user, %{user_id: user.id})
      _challenge_2 = ChallengeHelpers.create_multi_phase_challenge(user, %{user_id: user.id})

      assert length(Phases.all(filter: %{"challenge_id" => challenge.id})) === 3
    end
  end

  describe "retrieving a phase in a challenge from an ID" do
    test "success" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})

      phase_id = Enum.at(challenge.phases, 0).id
      {:ok, phase} = Phases.get(phase_id)

      assert phase.challenge_id === challenge.id
    end

    test "failure: not found" do
      assert Phases.get(-1) === {:error, :not_found}
    end
  end
end
