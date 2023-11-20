defmodule ChallengeGov.SubmissionDocumentsTest do
  use ChallengeGov.DataCase

  alias ChallengeGov.Submissions
  alias ChallengeGov.SubmissionDocuments
  alias ChallengeGov.TestHelpers.AccountHelpers
  alias ChallengeGov.TestHelpers.ChallengeHelpers
  alias ChallengeGov.TestHelpers.SubmissionHelpers
  alias ChallengeGov.TestHelpers.SubmissionDocumentHelpers

  describe "uploading documents" do
    test "successfully" do
      user = AccountHelpers.create_user()

      {:ok, document} =
        SubmissionDocuments.upload(user, %{
          "file" => %{path: "test/fixtures/test.pdf"},
          "name" => "Test File Name"
        })

      assert document.user_id == user.id
      assert document.extension == ".pdf"
      assert document.key
      assert document.name === "Test File Name"
    end
  end

  describe "attaching to a submission" do
    test "successfully" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})
      submission = SubmissionHelpers.create_submitted_submission(%{}, user, challenge)

      document =
        SubmissionDocumentHelpers.upload_document(
          user,
          "test/fixtures/test.pdf",
          "Test File Name"
        )

      {:ok, document} = SubmissionDocuments.attach_to_submission(document, submission)

      assert document.submission_id == submission.id
      assert document.name === "Test File Name"
    end

    test "already assigned" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})
      submission_1 = SubmissionHelpers.create_submitted_submission(%{}, user, challenge)
      submission_2 = SubmissionHelpers.create_submitted_submission(%{}, user, challenge)

      document = SubmissionDocumentHelpers.upload_document(user, "test/fixtures/test.pdf")

      {:ok, document} = SubmissionDocuments.attach_to_submission(document, submission_1)
      {:error, _changeset} = SubmissionDocuments.attach_to_submission(document, submission_2)

      assert document.name === ""
    end

    test "attempting to assign another user's submission" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})

      user_1 = AccountHelpers.create_user(%{email: "user1@example.com"})
      submission_1 = SubmissionHelpers.create_submitted_submission(%{}, user_1, challenge)

      user_2 = AccountHelpers.create_user(%{email: "user2@example.com"})
      document = SubmissionDocumentHelpers.upload_document(user_2, "test/fixtures/test.pdf")

      {:error, _changeset} = SubmissionDocuments.attach_to_submission(document, submission_1)
    end
  end

  describe "deleting a document" do
    test "successfully" do
      user = AccountHelpers.create_user()
      document = SubmissionDocumentHelpers.upload_document(user, "test/fixtures/test.pdf")

      {:ok, _document} = SubmissionDocuments.delete(document)
    end
  end

  describe "preserving uploaded document(s) on form error" do
    test "successfully" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})
      phase = Enum.at(challenge.phases, 0)

      document =
        SubmissionDocumentHelpers.upload_document(
          user,
          "test/fixtures/test.pdf",
          "Test File Name"
        )

      {:error, changeset} =
        Submissions.create_review(
          %{
            "action" => "review",
            "document_ids" => ["#{document.id}"],
            "documents" => [document],
            "submission" => %{
              "brief_description" => "brief description",
              "description" => "long description"
            }
          },
          user,
          challenge,
          phase
        )

      assert changeset.errors
      assert changeset.changes[:document_ids] === ["#{document.id}"]
      assert hd(changeset.changes[:document_objects]).name === document.name
    end
  end
end
