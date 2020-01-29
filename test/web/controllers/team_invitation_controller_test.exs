defmodule Web.AgencyInvittationControllerTest do
  use Web.ConnCase

  alias ChallengeGov.Agencies

  describe "creating a new invitation" do
    test "successfully", %{conn: conn} do
      inviter = TestHelpers.create_verified_user(%{email: "inviter@example.com"})
      team = TestHelpers.create_team(inviter)

      invitee = TestHelpers.create_verified_user(%{email: "invitee@example.com"})

      conn =
        conn
        |> assign(:current_user, inviter)
        |> post(Routes.team_invitation_path(conn, :create, team.id), user_id: invitee.id)

      assert redirected_to(conn) == Routes.team_path(conn, :show, team.id)
    end

    test "already invited", %{conn: conn} do
      inviter = TestHelpers.create_verified_user(%{email: "inviter@example.com"})
      team = TestHelpers.create_team(inviter)

      invitee = TestHelpers.create_verified_user(%{email: "invitee@example.com"})
      {:ok, _member} = Agencies.invite_member(team, inviter, invitee)

      conn =
        conn
        |> assign(:current_user, inviter)
        |> post(Routes.team_invitation_path(conn, :create, team.id), user_id: invitee.id)

      assert redirected_to(conn) == Routes.team_path(conn, :show, team.id)

      flash = Phoenix.Controller.get_flash(conn)
      assert flash["error"]
    end

    test "not a member", %{conn: conn} do
      team_member = TestHelpers.create_verified_user(%{email: "member@example.com"})
      team = TestHelpers.create_team(team_member)

      inviter = TestHelpers.create_verified_user(%{email: "inviter@example.com"})
      invitee = TestHelpers.create_verified_user(%{email: "invitee@example.com"})

      conn =
        conn
        |> assign(:current_user, inviter)
        |> post(Routes.team_invitation_path(conn, :create, team.id), user_id: invitee.id)

      assert redirected_to(conn) == Routes.team_path(conn, :show, team.id)

      flash = Phoenix.Controller.get_flash(conn)
      assert flash["error"]
    end
  end

  describe "accepting an invitation" do
    test "successfully", %{conn: conn} do
      inviter = TestHelpers.create_verified_user(%{email: "inviter@example.com"})
      team = TestHelpers.create_team(inviter)

      invitee = TestHelpers.create_verified_user(%{email: "invitee@example.com"})
      {:ok, _member} = Agencies.invite_member(team, inviter, invitee)

      conn =
        conn
        |> assign(:current_user, invitee)
        |> get(Routes.team_invitation_path(conn, :accept, team.id))

      assert redirected_to(conn) == Routes.team_path(conn, :show, team.id)

      flash = Phoenix.Controller.get_flash(conn)
      assert flash["info"]
    end

    test "no invite found", %{conn: conn} do
      inviter = TestHelpers.create_verified_user(%{email: "inviter@example.com"})
      team = TestHelpers.create_team(inviter)

      invitee = TestHelpers.create_verified_user(%{email: "invitee@example.com"})

      conn =
        conn
        |> assign(:current_user, invitee)
        |> get(Routes.team_invitation_path(conn, :accept, team.id))

      assert redirected_to(conn) == Routes.team_path(conn, :show, team.id)

      flash = Phoenix.Controller.get_flash(conn)
      assert flash["error"]
    end

    test "already a member", %{conn: conn} do
      inviter = TestHelpers.create_verified_user(%{email: "inviter@example.com"})
      team = TestHelpers.create_team(inviter)

      invitee = TestHelpers.create_verified_user(%{email: "invitee@example.com"})
      {:ok, _member} = Agencies.invite_member(team, inviter, invitee)
      {:ok, _member} = Agencies.accept_invite(team, invitee)

      conn =
        conn
        |> assign(:current_user, invitee)
        |> get(Routes.team_invitation_path(conn, :accept, team.id))

      assert redirected_to(conn) == Routes.team_path(conn, :show, team.id)

      flash = Phoenix.Controller.get_flash(conn)
      assert flash["error"]
    end
  end

  describe "rejecting an invitation" do
    test "successfully", %{conn: conn} do
      inviter = TestHelpers.create_verified_user(%{email: "inviter@example.com"})
      team = TestHelpers.create_team(inviter)

      invitee = TestHelpers.create_verified_user(%{email: "invitee@example.com"})
      {:ok, _member} = Agencies.invite_member(team, inviter, invitee)

      conn =
        conn
        |> assign(:current_user, invitee)
        |> get(Routes.team_invitation_path(conn, :reject, team.id))

      assert redirected_to(conn) == Routes.team_path(conn, :index)

      flash = Phoenix.Controller.get_flash(conn)
      assert flash["info"]
    end

    test "no invite found", %{conn: conn} do
      inviter = TestHelpers.create_verified_user(%{email: "inviter@example.com"})
      team = TestHelpers.create_team(inviter)

      invitee = TestHelpers.create_verified_user(%{email: "invitee@example.com"})

      conn =
        conn
        |> assign(:current_user, invitee)
        |> get(Routes.team_invitation_path(conn, :reject, team.id))

      assert redirected_to(conn) == Routes.team_path(conn, :index)

      flash = Phoenix.Controller.get_flash(conn)
      assert flash["error"]
    end

    test "already a member", %{conn: conn} do
      inviter = TestHelpers.create_verified_user(%{email: "inviter@example.com"})
      team = TestHelpers.create_team(inviter)

      invitee = TestHelpers.create_verified_user(%{email: "invitee@example.com"})
      {:ok, _member} = Agencies.invite_member(team, inviter, invitee)
      {:ok, _member} = Agencies.accept_invite(team, invitee)

      conn =
        conn
        |> assign(:current_user, invitee)
        |> get(Routes.team_invitation_path(conn, :reject, team.id))

      assert redirected_to(conn) == Routes.team_path(conn, :index)

      flash = Phoenix.Controller.get_flash(conn)
      assert flash["error"]
    end
  end
end
