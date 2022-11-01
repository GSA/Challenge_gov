defmodule ChallengeGov.ChallengeResourcesTest do
  use ChallengeGov.DataCase
  use Bamboo.Test

  alias ChallengeGov.Challenges
  alias ChallengeGov.TestHelpers.AccountHelpers
  alias ChallengeGov.TestHelpers.ChallengeHelpers

  describe "adding faq to challenge on resources section" do
    test "successfully" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})

      faq_text = "Test FAQ details"

      {:ok, challenge} =
        Challenges.update(
          challenge,
          %{
            "action" => "next",
            "challenge" => %{
              "section" => "resources",
              "faq" => faq_text
            }
          },
          user,
          ""
        )

      assert challenge.faq === faq_text
    end
  end
end
