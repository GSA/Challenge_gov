defmodule Web.SubmissionExportControllerTest do
  use Web.ConnCase

  alias ChallengeGov.TestHelpers.AccountHelpers
  alias ChallengeGov.TestHelpers.ChallengeHelpers

  describe "index" do
    test "success: as super admin", %{conn: conn} do
      user = AccountHelpers.create_user(%{role: "super_admin"})
      conn = prep_conn(conn, user)

      user2 = AccountHelpers.create_user(%{email: "user2@example.com", role: "challenge_manager"})

      challenge =
        ChallengeHelpers.create_closed_single_phase_challenge(user2, %{user_id: user2.id})

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

      user2 = AccountHelpers.create_user(%{email: "user2@example.com", role: "challenge_manager"})

      challenge =
        ChallengeHelpers.create_closed_single_phase_challenge(user2, %{user_id: user2.id})

      conn = get(conn, Routes.submission_export_path(conn, :index, challenge.id))

      %{
        user: user_in_assigns
      } = conn.assigns

      assert user === user_in_assigns

      assert html_response(conn, 200)
    end

    test "success: as challenge manager of challenge", %{conn: conn} do
      user = AccountHelpers.create_user(%{role: "challenge_manager"})
      conn = prep_conn(conn, user)

      challenge = ChallengeHelpers.create_closed_single_phase_challenge(user, %{user_id: user.id})

      conn = get(conn, Routes.submission_export_path(conn, :index, challenge.id))

      %{
        user: user_in_assigns
      } = conn.assigns

      assert user === user_in_assigns

      assert html_response(conn, 200)
    end

    test "failure: challenge has no closed phases", %{conn: conn} do
      user = AccountHelpers.create_user(%{role: "challenge_manager"})
      conn = prep_conn(conn, user)

      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})

      conn = get(conn, Routes.submission_export_path(conn, :index, challenge.id))

      assert get_flash(conn, :error) == "Challenge has no closed phases to export"
      assert html_response(conn, 302)
    end

    test "failure: challenge not found", %{conn: conn} do
      user = AccountHelpers.create_user(%{role: "challenge_manager"})
      conn = prep_conn(conn, user)

      conn = get(conn, Routes.submission_export_path(conn, :index, -1))

      assert conn.status === 302
      assert get_flash(conn, :error) === "Challenge not found"
      assert redirected_to(conn) == Routes.dashboard_path(conn, :index)
    end

    test "failure: as a different challenge manager", %{conn: conn} do
      user = AccountHelpers.create_user(%{role: "challenge_manager"})
      conn = prep_conn(conn, user)

      user2 = AccountHelpers.create_user(%{email: "user2@example.com", role: "challenge_manager"})
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

      user2 = AccountHelpers.create_user(%{email: "user2@example.com", role: "challenge_manager"})
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

  describe "create" do
    test "success: creating a submission export", %{conn: conn} do
      user = AccountHelpers.create_user(%{role: "super_admin"})
      conn = prep_conn(conn, user)

      user2 = AccountHelpers.create_user(%{email: "user2@example.com", role: "challenge_manager"})

      challenge =
        ChallengeHelpers.create_closed_single_phase_challenge(user2, %{user_id: user2.id})

      phase_ids =
        Enum.map(challenge.phases, fn phase ->
          to_string(phase.id)
        end)

      params = %{
        "phase_ids" => phase_ids,
        "judging_status" => "all",
        "format" => "csv"
      }

      conn = post(conn, Routes.submission_export_path(conn, :create, challenge.id), params)

      assert get_flash(conn, :info) === "Submission export created"
      assert redirected_to(conn) === Routes.submission_export_path(conn, :index, challenge.id)
    end

    test "failure: creating a submission export with no closed phases", %{conn: conn} do
      user = AccountHelpers.create_user(%{role: "super_admin"})
      conn = prep_conn(conn, user)

      user2 = AccountHelpers.create_user(%{email: "user2@example.com", role: "challenge_manager"})

      challenge = ChallengeHelpers.create_open_multi_phase_challenge(user2, %{user_id: user2.id})

      phase_ids =
        Enum.map(challenge.phases, fn phase ->
          to_string(phase.id)
        end)

      params = %{
        "phase_ids" => phase_ids,
        "judging_status" => "all",
        "format" => "csv"
      }

      conn = post(conn, Routes.submission_export_path(conn, :create, challenge.id), params)

      assert get_flash(conn, :error) === "All phases must be closed"
      assert redirected_to(conn) === Routes.submission_export_path(conn, :index, challenge.id)
    end
  end

  defp prep_conn(conn, user) do
    assign(conn, :current_user, user)
  end
end
