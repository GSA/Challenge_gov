defmodule Web.ExportControllerTest do
  use Web.ConnCase

  alias ChallengeGov.TestHelpers.AccountHelpers
  alias ChallengeGov.TestHelpers.ChallengeHelpers

  describe "export a challenge" do
    test "success: as csv", %{conn: conn} do
      conn = prep_conn(conn)
      %{current_user: user} = conn.assigns

      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id, status: "published"})

      conn = get(conn, Routes.export_path(conn, :export_challenge, challenge.id, "csv"))

      assert response_content_type(conn, :csv) === "text/csv"
    end

    test "success: as json", %{conn: conn} do
      conn = prep_conn(conn)
      %{current_user: user} = conn.assigns

      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id, status: "published"})

      conn = get(conn, Routes.export_path(conn, :export_challenge, challenge.id, "json"))

      assert response_content_type(conn, :json) === "application/json"
    end

    test "failure: invalid format", %{conn: conn} do
      conn = prep_conn(conn)
      %{current_user: user} = conn.assigns

      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id, status: "published"})

      conn = get(conn, Routes.export_path(conn, :export_challenge, challenge.id, "invalid"))

      assert get_flash(conn, :error) === "Invalid export format"
      assert redirected_to(conn) === Routes.dashboard_path(conn, :index)
    end

    test "failure: not authorized", %{conn: conn} do
      conn = prep_conn(conn, "challenge_manager")

      user_2 =
        AccountHelpers.create_user(%{email: "user_2@example.com", role: "challenge_manager"})

      challenge = ChallengeHelpers.create_challenge(%{user_id: user_2.id, status: "published"})

      conn = get(conn, Routes.export_path(conn, :export_challenge, challenge.id, "csv"))

      assert get_flash(conn, :error) === "You are not authorized to export this challenge"
      assert redirected_to(conn) === Routes.dashboard_path(conn, :index)
    end

    test "failure: challenge not found", %{conn: conn} do
      conn = prep_conn(conn)

      conn = get(conn, Routes.export_path(conn, :export_challenge, 1, "csv"))

      assert get_flash(conn, :error) === "Challenge not found"
      assert redirected_to(conn) === Routes.dashboard_path(conn, :index)
    end
  end

  defp prep_conn(conn, role \\ "admin") do
    user = AccountHelpers.create_user(%{role: role})
    assign(conn, :current_user, user)
  end
end
