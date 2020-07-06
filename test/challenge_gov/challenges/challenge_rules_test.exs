defmodule ChallengeGov.ChallengeRulesTest do
  use ChallengeGov.DataCase
  use Bamboo.Test

  alias ChallengeGov.Challenges
  alias ChallengeGov.TestHelpers.AccountHelpers
  alias ChallengeGov.TestHelpers.ChallengeHelpers

  describe "adding rules" do
    test "successfully" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})

      {:ok, updated_challenge} =
        Challenges.update(
          challenge,
          %{
            "action" => "next",
            "challenge" => %{
              "section" => "rules",
              "terms_equal_rules" => "false",
              "eligibility_requirements" => "Test eligibility",
              "rules" => "Test rules",
              "terms_and_conditions" => "Test terms and conditions",
              "legal_authority" => "Test legal authority"
            }
          },
          user,
          ""
        )

      assert updated_challenge.eligibility_requirements === "Test eligibility"
      assert updated_challenge.rules === "Test rules"
      assert updated_challenge.terms_and_conditions === "Test terms and conditions"
      assert updated_challenge.legal_authority === "Test legal authority"
    end

    test "successfully save as draft missing data" do
      user = AccountHelpers.create_user()

      challenge =
        ChallengeHelpers.create_challenge(%{
          user_id: user.id,
          eligibility_requirements: nil,
          rules: nil,
          terms_and_conditions: nil,
          legal_authority: nil
        })

      {:ok, updated_challenge} =
        Challenges.update(
          challenge,
          %{
            "action" => "save_draft",
            "challenge" => %{
              "section" => "rules"
            }
          },
          user,
          ""
        )

      assert updated_challenge.eligibility_requirements === nil
      assert updated_challenge.rules === nil
      assert updated_challenge.terms_and_conditions === nil
      assert updated_challenge.legal_authority === nil
    end

    test "failure missing fields" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})

      {:error, changeset} =
        Challenges.update(
          challenge,
          %{
            "action" => "next",
            "challenge" => %{
              "section" => "rules",
              "terms_equal_rules" => nil,
              "eligibility_requirements" => nil,
              "rules" => nil,
              "terms_and_conditions" => nil,
              "legal_authority" => nil
            }
          },
          user,
          ""
        )

      assert changeset.errors[:terms_equal_rules]
      assert changeset.errors[:eligibility_requirements]
      assert changeset.errors[:rules]
      assert changeset.errors[:terms_and_conditions]
      assert changeset.errors[:legal_authority]
    end

    test "success with terms equal rules" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})

      {:ok, challenge} =
        Challenges.update(
          challenge,
          %{
            "action" => "next",
            "challenge" => %{
              "section" => "rules",
              "terms_equal_rules" => "true",
              "eligibility_requirements" => "Test eligibility",
              "rules" => "Test rules",
              "rules_delta" => "Test rules",
              "legal_authority" => "Test legal authority"
            }
          },
          user,
          ""
        )

      assert challenge.terms_equal_rules
      assert challenge.eligibility_requirements === "Test eligibility"
      assert challenge.rules === "Test rules"
      assert challenge.terms_and_conditions === "Test rules"
      assert challenge.legal_authority === "Test legal authority"
    end

    test "failure terms required if terms not equal to rules" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})

      {:error, changeset} =
        Challenges.update(
          challenge,
          %{
            "action" => "next",
            "challenge" => %{
              "section" => "rules",
              "terms_equal_rules" => "false",
              "eligibility_requirements" => "Test eligibility",
              "rules" => "Test rules",
              "legal_authority" => "Test legal authority",
              "terms_and_conditions" => nil
            }
          },
          user,
          ""
        )

      assert !changeset.errors[:terms_equal_rules]
      assert !changeset.errors[:eligibility_requirements]
      assert !changeset.errors[:rules]
      assert changeset.errors[:terms_and_conditions]
      assert !changeset.errors[:legal_authority]
    end
  end
end
