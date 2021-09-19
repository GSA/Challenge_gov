defmodule Web.SubmissionInviteControllerTest do
  use Web.ConnCase

  alias ChallengeGov.Submissions
  alias ChallengeGov.SubmissionInvites
  alias ChallengeGov.TestHelpers.AccountHelpers
  alias ChallengeGov.TestHelpers.ChallengeHelpers
  alias ChallengeGov.TestHelpers.SubmissionHelpers

  describe "index" do
    test "success: as super admin", %{conn: conn} do
      user = AccountHelpers.create_user(%{role: "super_admin"})
      conn = prep_conn(conn, user)

      user2 = AccountHelpers.create_user(%{email: "user2@example.com", role: "challenge_manager"})
      challenge = ChallengeHelpers.create_single_phase_challenge(user2, %{user_id: user2.id})
      phase = Enum.at(challenge.phases, 0)

      submissions =
        Submissions.all(filter: %{"phase_id" => phase.id, "judging_status" => "winner"})

      conn = get(conn, Routes.submission_invite_path(conn, :index, phase.id))

      %{
        user: user_in_assigns,
        challenge: _challenge,
        submissions: submissions_in_assigns
      } = conn.assigns

      assert user === user_in_assigns
      assert submissions === submissions_in_assigns

      assert html_response(conn, 200)
    end
  end

  describe "show" do
    test "success: as super admin", %{conn: conn} do
      user = AccountHelpers.create_user(%{role: "super_admin"})
      conn = prep_conn(conn, user)

      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})
      phase = Enum.at(challenge.phases, 0)

      solver = AccountHelpers.create_user(%{email: "solver@example.com"})
      submission = SubmissionHelpers.create_submitted_submission(%{}, solver, challenge)

      params = %{
        "message" => "message text",
        "message_delta" => "message delta"
      }

      {:ok, submission_invite} = SubmissionInvites.create(params, submission)

      conn = get(conn, Routes.submission_invite_path(conn, :show, phase.id, submission_invite.id))

      assert html_response(conn, 200)
    end
  end

  describe "bulk create" do
    test "success: as super admin", %{conn: conn} do
      user = AccountHelpers.create_user(%{role: "super_admin"})
      conn = prep_conn(conn, user)

      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})
      phase = Enum.at(challenge.phases, 0)

      solver = AccountHelpers.create_user(%{email: "solver@example.com"})
      submission1 = SubmissionHelpers.create_submitted_submission(%{}, solver, challenge)
      submission2 = SubmissionHelpers.create_submitted_submission(%{}, solver, challenge)
      submission3 = SubmissionHelpers.create_submitted_submission(%{}, solver, challenge)

      submission_ids = [
        submission1.id,
        submission2.id,
        submission3.id
      ]

      params = %{
        "message" => "message text",
        "message_delta" => "message delta",
        "submission_ids" => submission_ids
      }

      conn = post(conn, Routes.submission_invite_path(conn, :create, phase.id, params))

      assert redirected_to(conn) == Routes.submission_invite_path(conn, :index, phase.id)
    end
  end

  describe "accept" do
    test "success", %{conn: conn} do
      user = AccountHelpers.create_user(%{role: "super_admin"})
      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})
      phase = Enum.at(challenge.phases, 0)

      solver = AccountHelpers.create_user(%{email: "solver@example.com"})
      submission = SubmissionHelpers.create_submitted_submission(%{}, solver, challenge, phase)

      conn = prep_conn(conn, solver)

      params = %{
        "message" => "message text",
        "message_delta" => "message delta"
      }

      {:ok, submission_invite} = SubmissionInvites.create(params, submission)

      conn = post(conn, Routes.submission_invite_path(conn, :accept, submission_invite.id))

      {:ok, submission_invite} = SubmissionInvites.get(submission_invite.id)

      assert submission_invite.status === "accepted"
      assert html_response(conn, 200)
    end
  end

  describe "revoke" do
    test "success", %{conn: conn} do
      user = AccountHelpers.create_user(%{role: "super_admin"})
      conn = prep_conn(conn, user)

      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})
      phase = Enum.at(challenge.phases, 0)

      solver = AccountHelpers.create_user(%{email: "solver@example.com"})
      submission = SubmissionHelpers.create_submitted_submission(%{}, solver, challenge, phase)

      params = %{
        "message" => "message text",
        "message_delta" => "message delta"
      }

      {:ok, submission_invite} = SubmissionInvites.create(params, submission)

      conn = post(conn, Routes.submission_invite_path(conn, :revoke, submission_invite.id))

      {:ok, submission_invite} = SubmissionInvites.get(submission_invite.id)

      assert submission_invite.status === "revoked"
      assert get_flash(conn, :error) == "Invite revoked"
      assert redirected_to(conn) == Routes.submission_invite_path(conn, :index, phase.id)
    end
  end

  defp prep_conn(conn, user) do
    assign(conn, :current_user, user)
  end
end
