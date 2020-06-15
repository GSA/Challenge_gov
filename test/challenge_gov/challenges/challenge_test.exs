defmodule ChallengeGov.ChallengeTest do
  use ChallengeGov.DataCase
  use Bamboo.Test

  alias ChallengeGov.Challenges
  alias ChallengeGov.TestHelpers.AccountHelpers
  alias ChallengeGov.TestHelpers.ChallengeHelpers

  describe "find start date" do
    test "successfully from single phase" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})

      start_date = Challenges.find_start_date(challenge)
      first_date = Timex.now()

      assert length(challenge.phases) === 1
      assert Timex.equal?(start_date, first_date)
    end

    test "successfully from multi phase" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_multi_phase_challenge(user, %{user_id: user.id})

      start_date = Challenges.find_start_date(challenge)
      first_date = Timex.shift(Timex.now(), hours: 1)

      assert length(challenge.phases) === 3
      assert Timex.equal?(start_date, first_date)
    end
  end
end
