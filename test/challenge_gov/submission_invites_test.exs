defmodule ChallengeGov.SubmissionInvitesTest do
  use ChallengeGov.DataCase
  use Bamboo.Test

  alias ChallengeGov.Emails
  alias ChallengeGov.SubmissionInvites
  alias ChallengeGov.TestHelpers.AccountHelpers
  alias ChallengeGov.TestHelpers.ChallengeHelpers
  alias ChallengeGov.TestHelpers.SubmissionHelpers

  describe "creating a submission invite" do
    test "success" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})
      submission = SubmissionHelpers.create_submitted_submission(%{}, user, challenge)

      params = %{
        "message" => "message text",
        "message_delta" => "message delta"
      }

      {:ok, submission_invite} = SubmissionInvites.create(params, submission)

      assert_delivered_email(Emails.submission_invite(submission_invite))
      assert submission_invite
    end
  end

  describe "bulk creating submission invites from ids" do
    test "success" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})

      solver = AccountHelpers.create_user(%{email: "solver@example.com"})
      submission1 = SubmissionHelpers.create_submitted_submission(%{}, solver, challenge)
      submission2 = SubmissionHelpers.create_submitted_submission(%{}, solver, challenge)
      submission3 = SubmissionHelpers.create_submitted_submission(%{}, solver, challenge)

      params = %{
        "message" => "message text",
        "message_delta" => "message delta"
      }

      submission_ids = [
        submission1.id,
        submission2.id,
        submission3.id
      ]

      {:ok, submission_invites} = SubmissionInvites.bulk_create(params, submission_ids)

      Enum.each(submission_invites, fn {_k, v} ->
        assert_delivered_email(Emails.submission_invite(v))
      end)

      assert length(Map.keys(submission_invites)) === 3
    end
  end

  describe "retrieving a submission invite" do
    test "success" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})
      submission = SubmissionHelpers.create_submitted_submission(%{}, user, challenge)

      params = %{
        "message" => "message text",
        "message_delta" => "message delta"
      }

      {:ok, submission_invite} = SubmissionInvites.create(params, submission)

      {:ok, retrieved_submission_invite} = SubmissionInvites.get(submission_invite.id)

      assert submission_invite.id === retrieved_submission_invite.id
    end
  end

  describe "accepting a submission invite" do
    test "success" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})
      submission = SubmissionHelpers.create_submitted_submission(%{}, user, challenge)

      params = %{
        "message" => "message text",
        "message_delta" => "message delta"
      }

      {:ok, submission_invite} = SubmissionInvites.create(params, submission)
      assert submission_invite.status === "pending"

      {:ok, submission_invite} = SubmissionInvites.accept(submission_invite)
      assert submission_invite.status === "accepted"
    end
  end

  describe "revoking a submission invite" do
    test "success" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})
      submission = SubmissionHelpers.create_submitted_submission(%{}, user, challenge)

      params = %{
        "message" => "message text",
        "message_delta" => "message delta"
      }

      {:ok, submission_invite} = SubmissionInvites.create(params, submission)
      assert submission_invite.status === "pending"

      {:ok, submission_invite} = SubmissionInvites.revoke(submission_invite)
      assert submission_invite.status === "revoked"
    end
  end
end
