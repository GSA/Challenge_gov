defmodule Web.PhaseControllerTest do
  use Web.ConnCase

  alias ChallengeGov.TestHelpers.AccountHelpers
  alias ChallengeGov.TestHelpers.ChallengeHelpers

  describe "index for a challenge" do
    test "success: as super admin", %{conn: conn} do
      user = AccountHelpers.create_user(%{role: "super_admin"})
      conn = prep_conn(conn, user)

      user2 = AccountHelpers.create_user(%{email: "user2@example.com", role: "challenge_manager"})
      challenge = ChallengeHelpers.create_single_phase_challenge(user2, %{user_id: user2.id})
      _challenge_2 = ChallengeHelpers.create_single_phase_challenge(user2, %{user_id: user2.id})

      conn = get(conn, Routes.challenge_phase_path(conn, :index, challenge.id))

      %{
        user: user_in_assigns,
        phases: phases
      } = conn.assigns

      assert user === user_in_assigns

      assert length(phases) === 1

      assert html_response(conn, 200)
    end

    test "success: as admin", %{conn: conn} do
      user = AccountHelpers.create_user(%{role: "admin"})
      conn = prep_conn(conn, user)

      user2 = AccountHelpers.create_user(%{email: "user2@example.com", role: "challenge_manager"})
      challenge = ChallengeHelpers.create_single_phase_challenge(user2, %{user_id: user2.id})
      _challenge_2 = ChallengeHelpers.create_single_phase_challenge(user2, %{user_id: user2.id})

      conn = get(conn, Routes.challenge_phase_path(conn, :index, challenge.id))

      %{
        user: user_in_assigns,
        phases: phases
      } = conn.assigns

      assert user === user_in_assigns

      assert length(phases) === 1

      assert html_response(conn, 200)
    end

    test "success: as challenge manager of challenge", %{conn: conn} do
      user = AccountHelpers.create_user(%{role: "challenge_manager"})
      conn = prep_conn(conn, user)

      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})
      _challenge_2 = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})

      conn = get(conn, Routes.challenge_phase_path(conn, :index, challenge.id))

      %{
        user: user_in_assigns,
        phases: phases
      } = conn.assigns

      assert user === user_in_assigns

      assert length(phases) === 1

      assert html_response(conn, 200)
    end

    test "failure: challenge not found", %{conn: conn} do
      user = AccountHelpers.create_user(%{role: "challenge_manager"})
      conn = prep_conn(conn, user)

      conn = get(conn, Routes.challenge_phase_path(conn, :index, -1))

      %{
        user: user_in_assigns
      } = conn.assigns

      assert user === user_in_assigns
      assert conn.status === 302
      assert get_flash(conn, :error) === "Challenge not found"
      assert redirected_to(conn) == Routes.challenge_path(conn, :index)
    end

    test "failure: as a different challenge manager", %{conn: conn} do
      user = AccountHelpers.create_user(%{role: "challenge_manager"})
      conn = prep_conn(conn, user)

      user2 = AccountHelpers.create_user(%{email: "user2@example.com", role: "challenge_manager"})
      challenge = ChallengeHelpers.create_single_phase_challenge(user2, %{user_id: user2.id})
      _challenge_2 = ChallengeHelpers.create_single_phase_challenge(user2, %{user_id: user2.id})

      conn = get(conn, Routes.challenge_phase_path(conn, :index, challenge.id))

      %{
        user: user_in_assigns
      } = conn.assigns

      assert user === user_in_assigns

      assert conn.status === 302
      assert get_flash(conn, :error) === "You are not allowed to view this challenge's phases"
      assert redirected_to(conn) == Routes.challenge_path(conn, :index)
    end

    test "failure: as solver", %{conn: conn} do
      user = AccountHelpers.create_user(%{role: "solver"})
      conn = prep_conn(conn, user)

      user2 = AccountHelpers.create_user(%{email: "user2@example.com", role: "challenge_manager"})
      challenge = ChallengeHelpers.create_single_phase_challenge(user2, %{user_id: user2.id})
      _challenge_2 = ChallengeHelpers.create_single_phase_challenge(user2, %{user_id: user2.id})

      conn = get(conn, Routes.challenge_phase_path(conn, :index, challenge.id))

      %{
        current_user: user_in_assigns
      } = conn.assigns

      assert user === user_in_assigns

      assert conn.status === 302
      assert get_flash(conn, :error) === "You are not authorized"
      assert redirected_to(conn) == Routes.dashboard_path(conn, :index)
    end
  end

  describe "show for a phase" do
    test "success: as super admin", %{conn: conn} do
      user = AccountHelpers.create_user(%{role: "super_admin"})
      conn = prep_conn(conn, user)

      user2 = AccountHelpers.create_user(%{email: "user2@example.com", role: "challenge_manager"})
      challenge = ChallengeHelpers.create_single_phase_challenge(user2, %{user_id: user2.id})

      phase = Enum.at(challenge.phases, 0)

      conn = get(conn, Routes.challenge_phase_path(conn, :show, challenge.id, phase.id))

      %{
        user: user_in_assigns,
        phase: phase_in_assigns
      } = conn.assigns

      assert user === user_in_assigns
      assert phase.id === phase_in_assigns.id
      assert html_response(conn, 200)
    end

    test "success: as admin", %{conn: conn} do
      user = AccountHelpers.create_user(%{role: "admin"})
      conn = prep_conn(conn, user)

      user2 = AccountHelpers.create_user(%{email: "user2@example.com", role: "challenge_manager"})
      challenge = ChallengeHelpers.create_single_phase_challenge(user2, %{user_id: user2.id})

      phase = Enum.at(challenge.phases, 0)

      conn = get(conn, Routes.challenge_phase_path(conn, :show, challenge.id, phase.id))

      %{
        user: user_in_assigns,
        phase: phase_in_assigns
      } = conn.assigns

      assert user === user_in_assigns
      assert phase.id === phase_in_assigns.id
      assert html_response(conn, 200)
    end

    test "success: as challenge manager of challenge", %{conn: conn} do
      user = AccountHelpers.create_user(%{role: "challenge_manager"})
      conn = prep_conn(conn, user)

      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})

      phase = Enum.at(challenge.phases, 0)

      conn = get(conn, Routes.challenge_phase_path(conn, :show, challenge.id, phase.id))

      %{
        user: user_in_assigns,
        phase: phase_in_assigns
      } = conn.assigns

      assert user === user_in_assigns
      assert phase.id === phase_in_assigns.id
      assert html_response(conn, 200)
    end

    test "failure: challenge not found", %{conn: conn} do
      user = AccountHelpers.create_user(%{role: "challenge_manager"})
      conn = prep_conn(conn, user)

      conn = get(conn, Routes.challenge_phase_path(conn, :show, -1, -1))

      %{
        user: user_in_assigns
      } = conn.assigns

      assert user === user_in_assigns
      assert conn.status === 302
      assert get_flash(conn, :error) === "Phase not found"
      assert redirected_to(conn) == Routes.challenge_path(conn, :index)
    end

    test "failure: phase not found", %{conn: conn} do
      user = AccountHelpers.create_user(%{role: "challenge_manager"})
      conn = prep_conn(conn, user)

      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})

      conn = get(conn, Routes.challenge_phase_path(conn, :show, challenge.id, -1))

      %{
        user: user_in_assigns
      } = conn.assigns

      assert user === user_in_assigns
      assert conn.status === 302
      assert get_flash(conn, :error) === "Phase not found"
      assert redirected_to(conn) == Routes.challenge_path(conn, :index)
    end

    test "failure: as a different challenge manager", %{conn: conn} do
      user = AccountHelpers.create_user(%{role: "challenge_manager"})
      conn = prep_conn(conn, user)

      user2 = AccountHelpers.create_user(%{email: "user2@example.com", role: "challenge_manager"})
      challenge = ChallengeHelpers.create_single_phase_challenge(user2, %{user_id: user2.id})
      _challenge_2 = ChallengeHelpers.create_single_phase_challenge(user2, %{user_id: user2.id})

      phase = Enum.at(challenge.phases, 0)

      conn = get(conn, Routes.challenge_phase_path(conn, :show, challenge.id, phase.id))

      %{
        user: user_in_assigns
      } = conn.assigns

      assert user === user_in_assigns
      assert conn.status === 302
      assert get_flash(conn, :error) === "You are not allowed to view this phase"
      assert redirected_to(conn) == Routes.challenge_path(conn, :index)
    end

    test "failure: as a solver", %{conn: conn} do
      user = AccountHelpers.create_user(%{role: "solver"})
      conn = prep_conn(conn, user)

      user2 = AccountHelpers.create_user(%{email: "user2@example.com", role: "challenge_manager"})
      challenge = ChallengeHelpers.create_single_phase_challenge(user2, %{user_id: user2.id})
      _challenge_2 = ChallengeHelpers.create_single_phase_challenge(user2, %{user_id: user2.id})

      phase = Enum.at(challenge.phases, 0)

      conn = get(conn, Routes.challenge_phase_path(conn, :show, challenge.id, phase.id))

      %{
        current_user: user_in_assigns
      } = conn.assigns

      assert user === user_in_assigns

      assert conn.status === 302
      assert get_flash(conn, :error) === "You are not authorized"
      assert redirected_to(conn) == Routes.dashboard_path(conn, :index)
    end
  end

  defp prep_conn(conn, user) do
    assign(conn, :current_user, user)
  end
end
