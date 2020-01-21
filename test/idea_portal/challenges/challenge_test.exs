defmodule ChallengeGov.Challenges.ChallengeTest do
  use ExUnit.Case
  use ChallengeGov.DataCase

  alias ChallengeGov.Challenges.Challenge

  describe "create validations" do
    test "focus area must be in the list" do
      user = TestHelpers.create_user()
      user = TestHelpers.verify_email(user)

      changeset = Challenge.create_changeset(%Challenge{}, %{focus_area: "Housing"}, user)
      refute changeset.errors[:focus_area]

      changeset = Challenge.create_changeset(%Challenge{}, %{focus_area: "Other"}, user)
      assert changeset.errors[:focus_area]
    end

    test "sets submitter first name automatically" do
      user = TestHelpers.create_user()
      user = TestHelpers.verify_email(user)

      changeset = Challenge.create_changeset(%Challenge{}, %{}, user)
      assert changeset.changes[:submitter_first_name]
    end

    test "sets submitter last name automatically" do
      user = TestHelpers.create_user()
      user = TestHelpers.verify_email(user)

      changeset = Challenge.create_changeset(%Challenge{}, %{}, user)
      assert changeset.changes[:submitter_last_name]
    end

    test "sets submitter email automatically" do
      user = TestHelpers.create_user()
      user = TestHelpers.verify_email(user)

      changeset = Challenge.create_changeset(%Challenge{}, %{}, user)
      assert changeset.changes[:submitter_email]
    end

    test "sets submitter phone number automatically" do
      user = TestHelpers.create_user()
      user = TestHelpers.verify_email(user)

      changeset = Challenge.create_changeset(%Challenge{}, %{}, user)
      assert changeset.changes[:submitter_phone]
    end

    test "sets captured_on automatically" do
      user = TestHelpers.create_user()
      user = TestHelpers.verify_email(user)

      changeset = Challenge.create_changeset(%Challenge{}, %{}, user)
      assert changeset.changes[:captured_on]
    end
  end

  describe "update validations" do
    test "does not set captured_on" do
      changeset = Challenge.update_changeset(%Challenge{}, %{})
      refute changeset.changes[:captured_on]
    end
  end
end
