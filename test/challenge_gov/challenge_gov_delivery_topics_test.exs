defmodule ChallengeGov.ChallengeGovDeliveryTopicsTest do
  use ChallengeGov.DataCase

  alias ChallengeGov.Challenges
  alias ChallengeGov.TestHelpers.AccountHelpers
  alias ChallengeGov.TestHelpers.ChallengeHelpers

  describe "Challenges to add topics" do
    test "open are available" do
      user = AccountHelpers.create_user()

      ChallengeHelpers.create_single_phase_challenge(user, %{
        user_id: user.id,
        status: "draft",
        challenge_managers: [user.id]
      })

      open_multi_phase_challenge =
        ChallengeHelpers.create_open_multi_phase_challenge(user, %{
          user_id: user.id,
          gov_delivery_topic: nil
        })

      Challenges.set_sub_statuses()

      challenges = ChallengeGov.Challenges.all_for_govdelivery()
      assert length(challenges) == 1
      assert List.first(challenges).id == open_multi_phase_challenge.id
    end
  end

  describe "Challenges to remove from topics" do
    test "3 months closed are no longer available" do
      user = AccountHelpers.create_user()

      open_multi_phase_challenge =
        ChallengeHelpers.create_open_multi_phase_challenge(user, %{
          user_id: user.id
        })

      Challenges.store_gov_delivery_topic(open_multi_phase_challenge, "CHAL-1")

      old_closed_multi_phase_challenge =
        ChallengeHelpers.create_old_archived_multi_phase_challenge(user, %{
          user_id: user.id
        })

      Challenges.store_gov_delivery_topic(old_closed_multi_phase_challenge, "CHAL-2")

      recently_closed_multi_phase_challenge =
        ChallengeHelpers.create_archived_multi_phase_challenge(user, %{
          user_id: user.id
        })

      Challenges.store_gov_delivery_topic(recently_closed_multi_phase_challenge, "CHAL-3")

      Challenges.set_sub_statuses()

      challenges = ChallengeGov.Challenges.all_for_removal_from_govdelivery()
      assert length(challenges) == 2

      challenge_ids = Enum.map(challenges, fn challenge -> challenge.id end)

      challenge_ids_to_check_against = [
        old_closed_multi_phase_challenge.id,
        recently_closed_multi_phase_challenge.id
      ]

      assert Enum.sort(challenge_ids) == Enum.sort(challenge_ids_to_check_against)
    end
  end
end
