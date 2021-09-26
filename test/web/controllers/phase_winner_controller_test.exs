defmodule Web.PhaseWinnerControllerTest do
  use Web.ConnCase

  alias ChallengeGov.TestHelpers.AccountHelpers
  alias ChallengeGov.TestHelpers.ChallengeHelpers

  describe "Adding a phase winner" do
    test "success: add winners button enabled", %{conn: conn} do
      user = AccountHelpers.create_user(%{role: "challenge_manager"})
      conn = prep_conn(conn, user)

      challenge =
        ChallengeHelpers.create_closed_and_open_phased_multi_phase_challenge(user, %{
          user_id: user.id
        })

      conn = get(conn, Routes.challenge_path(conn, :show, challenge.id))

      assert html_response(conn, 200) =~
               "<a class=\"btn btn-primary\" href=\"/challenges/#{challenge.id}/winners\">Add winners</a>"
    end

    test "failure: add winners button disabled", %{conn: conn} do
      user = AccountHelpers.create_user(%{role: "challenge_manager"})
      conn = prep_conn(conn, user)

      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})

      conn = get(conn, Routes.challenge_path(conn, :show, challenge.id))

      assert html_response(conn, 200) =~
               "<a class=\"btn btn-primary disabled\" href=\"#\" disabled>Add winners</a>"
    end

    test "success: show only closed phases", %{conn: conn} do
      user = AccountHelpers.create_user(%{role: "challenge_manager"})
      conn = prep_conn(conn, user)

      challenge =
        ChallengeHelpers.create_closed_and_open_phased_multi_phase_challenge(user, %{
          user_id: user.id
        })

      conn = get(conn, Routes.phase_winner_path(conn, :index, challenge.id))

      assert html_response(conn, 200) =~ "Winners for"
      assert html_response(conn, 200) =~ "Phase Test"
      refute html_response(conn, 200) =~ "Phase Test 2"
    end
  end

  defp prep_conn(conn, user) do
    assign(conn, :current_user, user)
  end
end
