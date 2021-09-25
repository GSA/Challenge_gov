defmodule ChallengeGov.SubmissionsTest do
  use ChallengeGov.DataCase
  use Bamboo.Test

  alias ChallengeGov.Emails
  alias ChallengeGov.Submissions
  alias ChallengeGov.SecurityLogs
  alias ChallengeGov.TestHelpers.AccountHelpers
  alias ChallengeGov.TestHelpers.ChallengeHelpers
  alias ChallengeGov.TestHelpers.SubmissionHelpers

  describe "creating a submission" do
    test "saving as draft with no data" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})
      phase = Enum.at(challenge.phases, 0)

      {:ok, submission} =
        Submissions.create_draft(
          %{
            "action" => "draft",
            "submission" => %{}
          },
          user,
          challenge,
          phase
        )

      assert submission.submitter_id === user.id
      assert submission.challenge_id === challenge.id
      assert is_nil(submission.title)
      assert submission.status === "draft"
    end

    test "saving as draft with data" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})
      phase = Enum.at(challenge.phases, 0)

      {:ok, submission} =
        Submissions.create_draft(
          %{
            "title" => "Test Title",
            "brief_description" => "Test Brief Description",
            "description" => "Test Description",
            "external_url" => "www.example.com"
          },
          user,
          challenge,
          phase
        )

      assert submission.submitter_id === user.id
      assert submission.challenge_id === challenge.id
      assert submission.title === "Test Title"
      assert submission.brief_description === "Test Brief Description"
      assert submission.description === "Test Description"
      assert submission.external_url === "www.example.com"
      assert submission.status === "draft"
    end

    test "submitting with no data" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})
      phase = Enum.at(challenge.phases, 0)

      {:error, changeset} =
        Submissions.create_review(
          %{
            "action" => "review",
            "submission" => %{}
          },
          user,
          challenge,
          phase
        )

      assert changeset.errors[:title]
      assert changeset.errors[:brief_description]
      assert changeset.errors[:description]
    end

    test "submitting with data" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})
      phase = Enum.at(challenge.phases, 0)

      {:ok, submission} =
        Submissions.create_review(
          %{
            "title" => "Test Title",
            "brief_description" => "Test Brief Description",
            "description" => "Test Description",
            "external_url" => "www.example.com",
            "terms_accepted" => "true",
            "review_verified" => "true"
          },
          user,
          challenge,
          phase
        )

      {:ok, submission} = Submissions.submit(submission)

      assert submission.submitter_id === user.id
      assert submission.challenge_id === challenge.id
      assert submission.title === "Test Title"
      assert submission.brief_description === "Test Brief Description"
      assert submission.description === "Test Description"
      assert submission.external_url === "www.example.com"
      assert submission.status === "submitted"
    end
  end

  describe "updating a submission" do
    test "update draft removing data" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})
      phase = Enum.at(challenge.phases, 0)

      submission = SubmissionHelpers.create_draft_submission(%{}, user, challenge, phase)

      {:ok, updated_submission} =
        Submissions.update_draft(
          submission,
          %{"title" => nil}
        )

      assert updated_submission.submitter_id === user.id
      assert updated_submission.challenge_id === challenge.id
      assert is_nil(updated_submission.title)
      assert updated_submission.brief_description === "Test Brief Description"
      assert updated_submission.description === "Test Description"
      assert updated_submission.external_url === "www.example.com"
      assert updated_submission.status === "draft"
    end

    test "update draft changing data" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})

      submission = SubmissionHelpers.create_draft_submission(%{}, user, challenge)

      {:ok, updated_submission} =
        Submissions.update_draft(
          submission,
          %{
            "title" => "New Test Title"
          }
        )

      assert updated_submission.submitter_id === user.id
      assert updated_submission.challenge_id === challenge.id
      assert updated_submission.title !== submission.title
      assert updated_submission.brief_description === submission.brief_description
      assert updated_submission.description === submission.description
      assert updated_submission.external_url === submission.external_url
      assert updated_submission.status === "draft"
    end

    test "update draft to submitted no other changes" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})

      submission = SubmissionHelpers.create_draft_submission(%{}, user, challenge)

      {:ok, updated_submission} = Submissions.submit(submission)

      assert updated_submission.submitter_id === user.id
      assert updated_submission.challenge_id === challenge.id
      assert updated_submission.title === submission.title
      assert updated_submission.brief_description === submission.brief_description
      assert updated_submission.description === submission.description
      assert updated_submission.external_url === submission.external_url
      assert updated_submission.status === "submitted"
    end

    test "update draft to submitted with invalid change" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})

      submission = SubmissionHelpers.create_draft_submission(%{}, user, challenge)

      {:error, changeset} =
        Submissions.update_review(
          submission,
          %{"title" => nil}
        )

      assert changeset.errors[:title]
    end

    test "update submitted" do
      user = AccountHelpers.create_user()
      user_2 = AccountHelpers.create_user(%{email: "user_2@example.com"})

      challenge =
        ChallengeHelpers.create_single_phase_challenge(user, %{
          user_id: user.id,
          challenge_managers: [user.id, user_2.id]
        })

      challenge = Repo.preload(challenge, [:challenge_manager_users])

      submission = SubmissionHelpers.create_submitted_submission(%{}, user, challenge)

      {:ok, updated_submission} =
        Submissions.update_review(
          submission,
          %{"title" => "New Test Title", "terms_accepted" => "true", "review_verified" => "true"}
        )

      {:ok, updated_submission} = Submissions.submit(updated_submission)

      assert updated_submission.submitter_id === user.id
      assert updated_submission.challenge_id === challenge.id
      assert updated_submission.title !== submission.title
      assert updated_submission.brief_description === submission.brief_description
      assert updated_submission.description === submission.description
      assert updated_submission.external_url === submission.external_url
      assert updated_submission.status === "submitted"
      assert_delivered_email(Emails.submission_confirmation(updated_submission))

      Enum.map(submission.challenge.challenge_manager_users, fn manager ->
        assert_delivered_email(Emails.new_submission_submission(manager, updated_submission))
      end)
    end

    test "update submitted with invalid value" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})

      submission = SubmissionHelpers.create_submitted_submission(%{}, user, challenge)

      {:error, changeset} =
        Submissions.update_review(
          submission,
          %{"title" => nil}
        )

      assert changeset.errors[:title]
    end
  end

  describe "deleting a submission" do
    test "successfully" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})

      submission = SubmissionHelpers.create_submitted_submission(%{}, user, challenge)

      {:ok, submission} = Submissions.delete(submission)

      assert !is_nil(submission.deleted_at)
    end
  end

  describe "fetching multiple submissions" do
    test "all submissions" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})

      SubmissionHelpers.create_submitted_submission(%{}, user, challenge)

      SubmissionHelpers.create_submitted_submission(%{}, user, challenge)

      SubmissionHelpers.create_submitted_submission(%{}, user, challenge)

      deleted_submission = SubmissionHelpers.create_submitted_submission(%{}, user, challenge)

      Submissions.delete(deleted_submission)

      submissions = Submissions.all()

      assert length(submissions) === 3
    end

    test "all submissions paginated" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})

      SubmissionHelpers.create_submitted_submission(%{}, user, challenge)

      SubmissionHelpers.create_submitted_submission(%{}, user, challenge)

      SubmissionHelpers.create_submitted_submission(%{}, user, challenge)

      deleted_submission = SubmissionHelpers.create_submitted_submission(%{}, user, challenge)

      Submissions.delete(deleted_submission)

      %{page: submissions, pagination: _pagination} = Submissions.all(page: 1, per: 1)

      assert length(submissions) === 1
    end

    test "filter by submitter id" do
      user = AccountHelpers.create_user()
      user_2 = AccountHelpers.create_user(%{email: "user_2@example.com"})
      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})

      SubmissionHelpers.create_submitted_submission(%{}, user_2, challenge)

      SubmissionHelpers.create_submitted_submission(%{}, user, challenge)

      SubmissionHelpers.create_submitted_submission(%{}, user, challenge)

      deleted_submission = SubmissionHelpers.create_submitted_submission(%{}, user_2, challenge)

      Submissions.delete(deleted_submission)

      submissions = Submissions.all(filter: %{"submitter_id" => user_2.id})

      assert length(submissions) === 1
    end

    test "filter by challenge id" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})
      challenge_2 = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})

      SubmissionHelpers.create_submitted_submission(%{}, user, challenge_2)

      SubmissionHelpers.create_submitted_submission(%{}, user, challenge)

      SubmissionHelpers.create_submitted_submission(%{}, user, challenge)

      deleted_submission = SubmissionHelpers.create_submitted_submission(%{}, user, challenge_2)

      Submissions.delete(deleted_submission)

      submissions = Submissions.all(filter: %{"challenge_id" => challenge_2.id})

      assert length(submissions) === 1
    end

    test "filter by search param" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})

      SubmissionHelpers.create_submitted_submission(%{}, user, challenge)

      SubmissionHelpers.create_submitted_submission(
        %{
          "title" => "Filtered Title"
        },
        user,
        challenge
      )

      SubmissionHelpers.create_submitted_submission(
        %{
          "brief_description" => "Filtered Brief Description"
        },
        user,
        challenge
      )

      SubmissionHelpers.create_submitted_submission(
        %{
          "description" => "Filtered Description"
        },
        user,
        challenge
      )

      SubmissionHelpers.create_submitted_submission(
        %{
          "external_url" => "www.example_filtered.com"
        },
        user,
        challenge
      )

      deleted_submission = SubmissionHelpers.create_submitted_submission(%{}, user, challenge)

      Submissions.delete(deleted_submission)

      deleted_submission =
        SubmissionHelpers.create_submitted_submission(
          %{
            "title" => "Filtered Title"
          },
          user,
          challenge
        )

      Submissions.delete(deleted_submission)

      deleted_submission =
        SubmissionHelpers.create_submitted_submission(
          %{
            "brief_description" => "Filtered Brief Description"
          },
          user,
          challenge
        )

      Submissions.delete(deleted_submission)

      deleted_submission =
        SubmissionHelpers.create_submitted_submission(
          %{
            "description" => "Filtered Description"
          },
          user,
          challenge
        )

      Submissions.delete(deleted_submission)

      deleted_submission =
        SubmissionHelpers.create_submitted_submission(
          %{
            "external_url" => "www.example_filtered.com"
          },
          user,
          challenge
        )

      Submissions.delete(deleted_submission)

      submissions = Submissions.all(filter: %{"search" => "Filtered"})

      assert length(submissions) === 4
    end

    test "filter by title" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})

      SubmissionHelpers.create_submitted_submission(
        %{
          "title" => "Filtered Title"
        },
        user,
        challenge
      )

      SubmissionHelpers.create_submitted_submission(%{}, user, challenge)

      SubmissionHelpers.create_submitted_submission(%{}, user, challenge)

      deleted_submission =
        SubmissionHelpers.create_submitted_submission(
          %{
            "title" => "Filtered Title"
          },
          user,
          challenge
        )

      Submissions.delete(deleted_submission)

      submissions = Submissions.all(filter: %{"title" => "Filtered Title"})

      assert length(submissions) === 1
    end

    test "filter by brief description" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})

      SubmissionHelpers.create_submitted_submission(
        %{
          "brief_description" => "Filtered Brief Description"
        },
        user,
        challenge
      )

      SubmissionHelpers.create_submitted_submission(%{}, user, challenge)

      SubmissionHelpers.create_submitted_submission(%{}, user, challenge)

      deleted_submission =
        SubmissionHelpers.create_submitted_submission(
          %{
            "brief_description" => "Filtered Brief Description"
          },
          user,
          challenge
        )

      Submissions.delete(deleted_submission)

      submissions =
        Submissions.all(filter: %{"brief_description" => "Filtered Brief Description"})

      assert length(submissions) === 1
    end

    test "filter by description" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})

      SubmissionHelpers.create_submitted_submission(
        %{
          "description" => "Filtered Description"
        },
        user,
        challenge
      )

      SubmissionHelpers.create_submitted_submission(%{}, user, challenge)

      SubmissionHelpers.create_submitted_submission(%{}, user, challenge)

      deleted_submission =
        SubmissionHelpers.create_submitted_submission(
          %{
            "description" => "Filtered Description"
          },
          user,
          challenge
        )

      Submissions.delete(deleted_submission)

      submissions = Submissions.all(filter: %{"description" => "Filtered Description"})

      assert length(submissions) === 1
    end

    test "filter by external url" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})

      SubmissionHelpers.create_submitted_submission(
        %{
          "external_url" => "www.example_filtered.com"
        },
        user,
        challenge
      )

      SubmissionHelpers.create_submitted_submission(%{}, user, challenge)

      SubmissionHelpers.create_submitted_submission(%{}, user, challenge)

      deleted_submission =
        SubmissionHelpers.create_submitted_submission(
          %{
            "external_url" => "www.example_filtered.com"
          },
          user,
          challenge
        )

      Submissions.delete(deleted_submission)

      submissions = Submissions.all(filter: %{"external_url" => "www.example_filtered.com"})

      assert length(submissions) === 1
    end

    test "filtering for exports" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_multi_phase_challenge(user, %{user_id: user.id})

      phase_1 = Enum.at(challenge.phases, 0)
      phase_2 = Enum.at(challenge.phases, 1)
      phase_3 = Enum.at(challenge.phases, 2)

      SubmissionHelpers.create_submitted_submission(%{}, user, challenge, phase_1)

      %{}
      |> SubmissionHelpers.create_submitted_submission(user, challenge, phase_1)
      |> Submissions.update_judging_status("selected")

      %{}
      |> SubmissionHelpers.create_submitted_submission(user, challenge, phase_1)
      |> Submissions.update_judging_status("winner")

      SubmissionHelpers.create_submitted_submission(%{}, user, challenge, phase_2)

      %{}
      |> SubmissionHelpers.create_submitted_submission(user, challenge, phase_2)
      |> Submissions.update_judging_status("selected")

      submissions =
        Submissions.all(
          filter: %{
            "phase_ids" => [phase_1.id, phase_2.id, phase_3.id],
            "judging_status" => "all"
          }
        )

      assert length(submissions) === 5

      submissions =
        Submissions.all(
          filter: %{
            "phase_ids" => [phase_1.id, phase_2.id, phase_3.id],
            "judging_status" => "selected"
          }
        )

      assert length(submissions) === 3

      submissions =
        Submissions.all(
          filter: %{
            "phase_ids" => [phase_1.id, phase_2.id, phase_3.id],
            "judging_status" => "winner"
          }
        )

      assert length(submissions) === 1

      submissions =
        Submissions.all(filter: %{"phase_ids" => [phase_1.id], "judging_status" => "all"})

      assert length(submissions) === 3

      submissions =
        Submissions.all(filter: %{"phase_ids" => [phase_2.id], "judging_status" => "all"})

      assert length(submissions) === 2

      submissions =
        Submissions.all(filter: %{"phase_ids" => [phase_3.id], "judging_status" => "all"})

      assert Enum.empty?(submissions)
    end
  end

  describe "fetching a submission" do
    test "successfully by id" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})

      submission = SubmissionHelpers.create_submitted_submission(%{}, user, challenge)

      {:ok, fetched_submission} = Submissions.get(submission.id)

      assert submission.id === fetched_submission.id
    end

    test "not found because of deletion" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})

      submission = SubmissionHelpers.create_submitted_submission(%{}, user, challenge)

      {:ok, deleted_submission} = Submissions.delete(submission)

      assert Submissions.get(deleted_submission.id) === {:error, :not_found}
    end

    test "not found" do
      assert Submissions.get(1) === {:error, :not_found}
    end
  end

  describe "updating judging status" do
    test "success: changing from unselected to selected" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})

      submission = SubmissionHelpers.create_submitted_submission(%{}, user, challenge)

      {:ok, updated_submission} = Submissions.update_judging_status(submission, "selected")

      assert submission.judging_status === "not_selected"
      assert updated_submission.judging_status === "selected"
    end

    test "success: changing from selected to unselected" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})

      submission = SubmissionHelpers.create_submitted_submission(%{}, user, challenge)

      {:ok, updated_submission} = Submissions.update_judging_status(submission, "selected")
      assert updated_submission.judging_status === "selected"

      {:ok, unselected_submission} =
        Submissions.update_judging_status(updated_submission, "not_selected")

      assert unselected_submission.judging_status === "not_selected"
    end

    test "failure: with invalid status" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})

      submission = SubmissionHelpers.create_submitted_submission(%{}, user, challenge)

      {:error, changeset} = Submissions.update_judging_status(submission, "invalid")
      assert changeset.errors[:judging_status]
    end
  end

  describe "security log" do
    test "tracks an event when a submission is submitted" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})
      submission = SubmissionHelpers.create_submitted_submission(%{}, user, challenge)

      log_event = Enum.at(SecurityLogs.all(), 1)

      assert log_event.action === "submit"
      assert log_event.originator_id === user.id
      assert log_event.originator_identifier === user.email
      assert log_event.target_id === submission.id
      assert log_event.target_identifier === submission.title
      assert log_event.target_type === "submission"
    end
  end
end
