defmodule ChallengeGov.ChallengePrizesTest do
  use ChallengeGov.DataCase
  use Bamboo.Test

  alias ChallengeGov.Challenges
  alias ChallengeGov.TestHelpers.AccountHelpers
  alias ChallengeGov.TestHelpers.ChallengeHelpers

  describe "adding prizes to challenges" do
    test "successfully adding monetary and non monetary" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})

      {:ok, updated_challenge} =
        Challenges.update(
          challenge,
          %{
            "action" => "next",
            "challenge" => %{
              "section" => "prizes",
              "prize_type" => "both",
              "prize_total" => "100.00",
              "non_monetary_prizes" => "Test non monetary prize",
              "prize_description" => "Test prize description"
            }
          },
          user,
          ""
        )

      assert updated_challenge.prize_type === "both"
      assert updated_challenge.prize_total === 10_000
      assert updated_challenge.non_monetary_prizes === "Test non monetary prize"
      assert updated_challenge.prize_description === "Test prize description"
    end

    test "successfully adding cash prize only" do
      user = AccountHelpers.create_user()

      challenge =
        ChallengeHelpers.create_challenge(%{
          user_id: user.id,
          non_monetary_prizes: "Test non-monetary value"
        })

      {:ok, updated_challenge} =
        Challenges.update(
          challenge,
          %{
            "action" => "next",
            "challenge" => %{
              "section" => "prizes",
              "prize_type" => "monetary",
              "prize_total" => "100.00"
            }
          },
          user,
          ""
        )

      assert updated_challenge.prize_type === "monetary"
      assert updated_challenge.prize_total === 10_000
      assert updated_challenge.non_monetary_prizes === nil
    end

    test "successfully adding non monetary prize only" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})

      {:ok, updated_challenge} =
        Challenges.update(
          challenge,
          %{
            "action" => "next",
            "challenge" => %{
              "section" => "prizes",
              "prize_type" => "non_monetary",
              "non_monetary_prizes" => "Test non monetary prize",
              "prize_total" => "$100.00"
            }
          },
          user,
          ""
        )

      assert updated_challenge.prize_type === "non_monetary"
      assert updated_challenge.non_monetary_prizes === "Test non monetary prize"
      assert updated_challenge.prize_total === 0
    end

    test "no prize description length" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})

      length = 15_001
      prize_description = TestHelpers.generate_random_string(length)

      assert {:ok, _} =
               Challenges.update(
                 challenge,
                 %{
                   "action" => "next",
                   "challenge" => %{
                     "section" => "prizes",
                     "prize_type" => "non_monetary",
                     "non_monetary_prizes" => "test non monetary prize",
                     "prize_description" => prize_description,
                     "prize_total" => 0
                   }
                 },
                 user,
                 ""
               )
    end

    test "failure prize type missing" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})

      {:error, changeset} =
        Challenges.update(
          challenge,
          %{
            "action" => "next",
            "challenge" => %{
              "prize_type" => nil,
              "section" => "prizes"
            }
          },
          user,
          ""
        )

      assert changeset.errors[:prize_type]
    end

    test "failure both missing" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})

      {:error, changeset} =
        Challenges.update(
          challenge,
          %{
            "action" => "next",
            "challenge" => %{
              "section" => "prizes",
              "prize_type" => "both",
              "prize_total" => "",
              "non_monetary_prizes" => ""
            }
          },
          user,
          ""
        )

      assert changeset.errors[:prize_total]
      assert changeset.errors[:non_monetary_prizes]
    end

    test "failure prize total missing" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})

      {:error, changeset} =
        Challenges.update(
          challenge,
          %{
            "action" => "next",
            "challenge" => %{
              "section" => "prizes",
              "prize_type" => "monetary",
              "prize_total" => ""
            }
          },
          user,
          ""
        )

      assert changeset.errors[:prize_total]
      assert !changeset.errors[:non_monetary_prizes]
    end

    test "failure invalid prize total" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})

      {:error, changeset} =
        Challenges.update(
          challenge,
          %{
            "action" => "next",
            "challenge" => %{
              "section" => "prizes",
              "prize_type" => "monetary",
              "prize_total" => "Not a number"
            }
          },
          user,
          ""
        )

      assert changeset.errors[:prize_total]
      assert !changeset.errors[:non_monetary_prizes]
    end

    test "failure non monetary prize missing" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})

      {:error, changeset} =
        Challenges.update(
          challenge,
          %{
            "action" => "next",
            "challenge" => %{
              "section" => "prizes",
              "prize_type" => "non_monetary",
              "prize_total" => "100.00"
            }
          },
          user,
          ""
        )

      assert !changeset.errors[:prize_total]
      assert changeset.errors[:non_monetary_prizes]
    end
  end
end
