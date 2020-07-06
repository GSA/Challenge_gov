defmodule ChallengeGov.ChallengeDetailsTest do
  use ChallengeGov.DataCase
  use Bamboo.Test

  alias ChallengeGov.Challenges
  alias ChallengeGov.TestHelpers
  alias ChallengeGov.TestHelpers.AccountHelpers
  alias ChallengeGov.TestHelpers.ChallengeHelpers

  describe "adding types" do
    test "successfully" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})

      types = Challenges.challenge_types()
      primary_type = Enum.at(types, 0)
      first_type = Enum.at(types, 1)
      second_type = Enum.at(types, 2)
      third_type = Enum.at(types, 3)
      other_type = "Test other type"

      {:ok, updated_challenge} =
        Challenges.update(
          challenge,
          %{
            "action" => "next",
            "challenge" => %{
              "section" => "details",
              "primary_type" => primary_type,
              "types" => [first_type, second_type, third_type],
              "other_type" => other_type
            }
          },
          user,
          ""
        )

      assert updated_challenge.primary_type === primary_type
      assert updated_challenge.types === [first_type, second_type, third_type]
      assert updated_challenge.other_type === other_type
    end

    test "validation errors" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})

      primary_type = "Invalid primary type"
      first_type = "Invalid type 1"
      second_type = "Invalid type 2"
      third_type = "Invalid type 3"
      length = 46
      other_type = TestHelpers.generate_random_string(length)

      {:error, changeset} =
        Challenges.update(
          challenge,
          %{
            "action" => "next",
            "challenge" => %{
              "section" => "details",
              "primary_type" => primary_type,
              "types" => [first_type, second_type, third_type],
              "other_type" => other_type
            }
          },
          user,
          ""
        )

      assert changeset.errors[:primary_type]
      assert changeset.errors[:types]
      assert changeset.errors[:other_type]
    end
  end
end
