defmodule IdeaPortal.TeamsTest do
  use IdeaPortal.DataCase

  alias IdeaPortal.Teams

  describe "creating a team" do
    test "successful" do
      user = TestHelpers.create_user()
      user = TestHelpers.verify_email(user)

      {:ok, team} =
        Teams.create(user, %{
          name: "Team 1",
          description: "Working on a project"
        })

      assert team.name == "Team 1"

      team = Repo.preload(team, [:members])
      assert length(team.members) == 1
    end

    test "failure" do
      user = TestHelpers.create_user()
      user = TestHelpers.verify_email(user)

      assert {:error, _changeset} = Teams.create(user, %{})
    end

    test "email is not verified" do
      user = TestHelpers.create_user()

      assert {:error, _changeset} =
               Teams.create(user, %{
                 name: "Team 1",
                 description: "Working on a project"
               })
    end

    test "already in a team" do
      user = TestHelpers.create_user()
      user = TestHelpers.verify_email(user)

      {:ok, _team} = Teams.create(user, %{name: "Team 1"})

      {:error, changeset} = Teams.create(user, %{name: "Team 2"})
      assert %Teams.Team{} = changeset.data
    end
  end

  describe "deleting a team" do
    test "soft delete" do
      user = TestHelpers.create_user()
      user = TestHelpers.verify_email(user)

      team = TestHelpers.create_team(user)

      {:ok, team} = Teams.delete(team)

      assert team.deleted_at
    end
  end
end
