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

    test "include an avatar" do
      user = TestHelpers.create_user()
      user = TestHelpers.verify_email(user)

      {:ok, team} =
        Teams.create(user, %{
          name: "Team 1",
          description: "Working on a project",
          avatar: %{path: "test/fixtures/test.png"}
        })

      assert team.avatar_key
      assert team.avatar_extension == ".png"
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

  describe "updating a team" do
    test "successful" do
      user = TestHelpers.create_user()
      user = TestHelpers.verify_email(user)
      team = TestHelpers.create_team(user)

      {:ok, team} = Teams.update(team, %{name: "Updated Name"})

      assert team.name == "Updated Name"
    end

    test "include an avatar" do
      user = TestHelpers.create_user()
      user = TestHelpers.verify_email(user)
      team = TestHelpers.create_team(user)

      {:ok, team} =
        Teams.update(team, %{
          avatar: %{path: "test/fixtures/test.png"}
        })

      assert team.avatar_key
      assert team.avatar_extension == ".png"
    end

    test "failure" do
      user = TestHelpers.create_user()
      user = TestHelpers.verify_email(user)
      team = TestHelpers.create_team(user)

      {:error, _changeset} = Teams.update(team, %{name: nil})
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

    test "archives team members" do
      user = TestHelpers.create_user()
      user = TestHelpers.verify_email(user)

      team = TestHelpers.create_team(user)

      {:ok, team} = Teams.delete(team)

      assert team.deleted_at

      team = Repo.preload(team, :members, force: true)
      assert Enum.map(team.members, & &1.status) == ["archived"]
    end
  end

  describe "inviting a new member" do
    test "sends an email" do
      inviter = TestHelpers.create_verified_user(%{email: "inviter@example.com"})
      team = TestHelpers.create_team(inviter)

      invitee = TestHelpers.create_verified_user(%{email: "invitee@example.com"})

      {:ok, member} = Teams.invite_member(team, inviter, invitee)

      assert member.status == "invited"
    end

    test "returns a good error if already part of a team" do
      inviter = TestHelpers.create_verified_user(%{email: "inviter@example.com"})
      team = TestHelpers.create_team(inviter)

      invitee = TestHelpers.create_verified_user(%{email: "invitee@example.com"})

      {:ok, _member} = Teams.invite_member(team, inviter, invitee)
      {:ok, _member} = Teams.accept_invite(team, invitee)

      {:error, :already_member} = Teams.invite_member(team, inviter, invitee)
    end

    test "allows sending multiple invites" do
      invitee = TestHelpers.create_verified_user(%{email: "invitee@example.com"})

      inviter = TestHelpers.create_verified_user(%{email: "inviter1@example.com"})
      team = TestHelpers.create_team(inviter)
      {:ok, member} = Teams.invite_member(team, inviter, invitee)
      assert member.status == "invited"

      inviter = TestHelpers.create_verified_user(%{email: "inviter2@example.com"})
      team = TestHelpers.create_team(inviter)
      {:ok, member} = Teams.invite_member(team, inviter, invitee)
      assert member.status == "invited"
    end
  end

  describe "accepting an invitation" do
    test "accepting the invitation makes a full member" do
      inviter = TestHelpers.create_verified_user(%{email: "inviter@example.com"})
      team = TestHelpers.create_team(inviter)

      invitee = TestHelpers.create_verified_user(%{email: "invitee@example.com"})

      {:ok, _member} = Teams.invite_member(team, inviter, invitee)
      {:ok, member} = Teams.accept_invite(team, invitee)

      assert member.status == "accepted"
    end

    test "trying to accept an unknown invite" do
      inviter = TestHelpers.create_verified_user(%{email: "inviter@example.com"})
      team = TestHelpers.create_team(inviter)

      invitee = TestHelpers.create_verified_user(%{email: "invitee@example.com"})

      {:error, :not_found} = Teams.accept_invite(team, invitee)
    end

    test "accepting an invite clears the rest of the pending invites" do
      invitee = TestHelpers.create_verified_user(%{email: "invitee@example.com"})

      inviter = TestHelpers.create_verified_user(%{email: "inviter1@example.com"})
      team1 = TestHelpers.create_team(inviter)
      {:ok, _member} = Teams.invite_member(team1, inviter, invitee)

      inviter = TestHelpers.create_verified_user(%{email: "inviter2@example.com"})
      team2 = TestHelpers.create_team(inviter)
      {:ok, member2} = Teams.invite_member(team2, inviter, invitee)

      {:ok, _member} = Teams.accept_invite(team1, invitee)

      member2 = Repo.get(Teams.Member, member2.id)
      assert member2.status == "rejected"
    end
  end

  describe "rejecting an invite" do
    test "marks an invited as rejected" do
      inviter = TestHelpers.create_verified_user(%{email: "inviter@example.com"})
      team = TestHelpers.create_team(inviter)

      invitee = TestHelpers.create_verified_user(%{email: "invitee@example.com"})

      {:ok, _member} = Teams.invite_member(team, inviter, invitee)
      {:ok, member} = Teams.reject_invite(team, invitee)

      assert member.status == "rejected"
    end

    test "once rejected, cannot be invited back" do
      inviter = TestHelpers.create_verified_user(%{email: "inviter@example.com"})
      team = TestHelpers.create_team(inviter)

      invitee = TestHelpers.create_verified_user(%{email: "invitee@example.com"})

      {:ok, _member} = Teams.invite_member(team, inviter, invitee)
      {:ok, _member} = Teams.reject_invite(team, invitee)
      {:error, _changeset} = Teams.invite_member(team, inviter, invitee)
    end
  end
end
