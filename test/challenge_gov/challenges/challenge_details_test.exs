defmodule ChallengeGov.ChallengeDetailsTest do
  use ChallengeGov.DataCase
  use Bamboo.Test

  alias ChallengeGov.Challenges
  alias ChallengeGov.TestHelpers
  alias ChallengeGov.TestHelpers.AccountHelpers
  alias ChallengeGov.TestHelpers.ChallengeHelpers

  describe "submitting challenge" do
    test "failure: validations" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})

      {:error, changeset} =
        Challenges.update(
          challenge,
          %{
            "action" => "next",
            "challenge" => %{
              "section" => "details",
              "title" => TestHelpers.generate_random_string(91),
              "tagline" => TestHelpers.generate_random_string(401)
            }
          },
          user,
          ""
        )

      assert changeset.errors[:title]
      assert changeset.errors[:tagline]
    end
  end

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

  describe "adding phases" do
    test "success - changing phases resets sub_status" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})
      {:ok, challenge} = Challenges.update(challenge, %{"sub_status" => "archived"}, user, "")
      phase = Enum.at(challenge.phases, 0)

      assert challenge.sub_status === "archived"

      {:ok, updated_challenge} =
        Challenges.update(
          challenge,
          %{
            "action" => "next",
            "challenge" => %{
              "section" => "details",
              "phases" => %{
                "0" => %{
                  "id" => phase.id,
                  "end_date" => "2020-10-01 03:59:00Z",
                  "how_to_enter" => "<p>ASDFASDF</p>",
                  "how_to_enter_delta" => "{\"ops\":[{\"insert\":\"ASDFASDF\\n\"}]}",
                  "judging_criteria" => "",
                  "judging_criteria_delta" => "",
                  "open_to_submissions" => "true",
                  "start_date" => "2020-09-15 09:00:00Z",
                  "title" => ""
                }
              }
            }
          },
          user,
          ""
        )

      assert updated_challenge.sub_status === nil
    end
  end

  describe "updating a published challenge" do
    test "success - with auto publish date in the past" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})

      {:ok, challenge} =
        Challenges.update(
          challenge,
          %{
            "action" => "next",
            "challenge" => %{
              "section" => "details",
              "status" => "published",
              "auto_publish_date" => TestHelpers.iso_timestamp(days: -5)
            }
          },
          user,
          ""
        )

      assert challenge.status === "published"

      {:ok, updated_challenge} =
        Challenges.update(
          challenge,
          %{
            "action" => "next",
            "challenge" => %{
              "section" => "details",
              "brief_description" => "Updated brief description"
            }
          },
          user,
          ""
        )

      assert updated_challenge.brief_description === "Updated brief description"
    end
  end
end
