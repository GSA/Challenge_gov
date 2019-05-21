defmodule IdeaPortal.Challenges.ChallengeTest do
  use ExUnit.Case

  alias IdeaPortal.Challenges.Challenge

  describe "create validations" do
    test "focus area must be in the list" do
      changeset = Challenge.create_changeset(%Challenge{}, %{focus_area: "Housing"})
      refute changeset.errors[:focus_area]

      changeset = Challenge.create_changeset(%Challenge{}, %{focus_area: "Other"})
      assert changeset.errors[:focus_area]
    end

    test "sets captured_on automatically" do
      changeset = Challenge.create_changeset(%Challenge{}, %{})
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
