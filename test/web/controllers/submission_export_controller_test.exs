defmodule Web.SubmissionExportControllerTest do
  use Web.ConnCase

  alias ChallengeGov.TestHelpers.AccountHelpers
  alias ChallengeGov.TestHelpers.ChallengeHelpers

  describe "index" do
    test "success: as super admin", %{conn: conn} do
      user = AccountHelpers.create_user(%{role: "super_admin"})
      conn = prep_conn(conn, user)

      user2 = AccountHelpers.create_user(%{email: "user2@example.com", role: "challenge_owner"})
      challenge = ChallengeHelpers.create_single_phase_challenge(user2, %{user_id: user2.id})

      conn = get(conn, Routes.submission_export_path(conn, :index, challenge.id))

      %{
        user: user_in_assigns
      } = conn.assigns

      assert user === user_in_assigns

      assert html_response(conn, 200)
    end

    test "success: as admin", %{conn: conn} do
      user = AccountHelpers.create_user(%{role: "admin"})
      conn = prep_conn(conn, user)

      user2 = AccountHelpers.create_user(%{email: "user2@example.com", role: "challenge_owner"})
      challenge = ChallengeHelpers.create_single_phase_challenge(user2, %{user_id: user2.id})

      conn = get(conn, Routes.submission_export_path(conn, :index, challenge.id))

      %{
        user: user_in_assigns
      } = conn.assigns

      assert user === user_in_assigns

      assert html_response(conn, 200)
    end

    test "success: as challenge owner of challenge", %{conn: conn} do
      user = AccountHelpers.create_user(%{role: "challenge_owner"})
      conn = prep_conn(conn, user)

      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})

      conn = get(conn, Routes.submission_export_path(conn, :index, challenge.id))

      %{
        user: user_in_assigns
      } = conn.assigns

      assert user === user_in_assigns

      assert html_response(conn, 200)
    end

    test "failure: challenge not found", %{conn: conn} do
      user = AccountHelpers.create_user(%{role: "challenge_owner"})
      conn = prep_conn(conn, user)

      conn = get(conn, Routes.submission_export_path(conn, :index, -1))

      assert conn.status === 302
      assert get_flash(conn, :error) === "Challenge not found"
      assert redirected_to(conn) == Routes.dashboard_path(conn, :index)
    end

    test "failure: as a different challenge owner", %{conn: conn} do
      user = AccountHelpers.create_user(%{role: "challenge_owner"})
      conn = prep_conn(conn, user)

      user2 = AccountHelpers.create_user(%{email: "user2@example.com", role: "challenge_owner"})
      challenge = ChallengeHelpers.create_single_phase_challenge(user2, %{user_id: user2.id})
      _challenge_2 = ChallengeHelpers.create_single_phase_challenge(user2, %{user_id: user2.id})

      conn = get(conn, Routes.submission_export_path(conn, :index, challenge.id))

      assert conn.status === 302

      assert get_flash(conn, :error) ===
               "You are not authorized to export this challenge's submissions"

      assert redirected_to(conn) == Routes.dashboard_path(conn, :index)
    end

    test "failure: as solver", %{conn: conn} do
      user = AccountHelpers.create_user(%{role: "solver"})
      conn = prep_conn(conn, user)

      user2 = AccountHelpers.create_user(%{email: "user2@example.com", role: "challenge_owner"})
      challenge = ChallengeHelpers.create_single_phase_challenge(user2, %{user_id: user2.id})
      _challenge_2 = ChallengeHelpers.create_single_phase_challenge(user2, %{user_id: user2.id})

      conn = get(conn, Routes.submission_export_path(conn, :index, challenge.id))

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
