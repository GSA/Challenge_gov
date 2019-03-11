defmodule IdeaPortal.ChallengesTest do
  use IdeaPortal.DataCase

  alias IdeaPortal.Challenges

  describe "submitting a new challenge" do
    test "successfully" do
      user = TestHelpers.create_user()

      {:ok, challenge} =
        Challenges.submit(user, %{
          focus_area: "Transportation",
          name: "Bike lanes",
          description: "We need more bike lanes",
          why: "To bike around"
        })

      assert challenge.user_id
    end

    test "with errors" do
      user = TestHelpers.create_user()

      {:error, changeset} =
        Challenges.submit(user, %{
          name: "Bike lanes",
          description: "We need more bike lanes",
          why: "To bike around"
        })

      assert changeset.errors[:focus_area]
    end
  end
end
