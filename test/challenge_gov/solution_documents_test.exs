defmodule ChallengeGov.SolutionDocumentsTest do
  use ChallengeGov.DataCase

  alias ChallengeGov.SolutionDocuments
  alias ChallengeGov.TestHelpers.AccountHelpers
  alias ChallengeGov.TestHelpers.ChallengeHelpers
  alias ChallengeGov.TestHelpers.SolutionHelpers
  alias ChallengeGov.TestHelpers.SolutionDocumentHelpers

  describe "uploading documents" do
    test "successfully" do
      user = AccountHelpers.create_user()

      {:ok, document} =
        SolutionDocuments.upload(user, %{
          "file" => %{path: "test/fixtures/test.pdf"},
          "name" => "Test File Name"
        })

      assert document.user_id == user.id
      assert document.extension == ".pdf"
      assert document.key
      assert document.name === "Test File Name"
    end
  end

  describe "attaching to a solution" do
    test "successfully" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})
      solution = SolutionHelpers.create_submitted_solution(%{}, user, challenge)

      document =
        SolutionDocumentHelpers.upload_document(user, "test/fixtures/test.pdf", "Test File Name")

      {:ok, document} = SolutionDocuments.attach_to_solution(document, solution)

      assert document.solution_id == solution.id
      assert document.name === "Test File Name"
    end

    test "already assigned" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})
      solution_1 = SolutionHelpers.create_submitted_solution(%{}, user, challenge)
      solution_2 = SolutionHelpers.create_submitted_solution(%{}, user, challenge)

      document = SolutionDocumentHelpers.upload_document(user, "test/fixtures/test.pdf")

      {:ok, document} = SolutionDocuments.attach_to_solution(document, solution_1)
      {:error, _changeset} = SolutionDocuments.attach_to_solution(document, solution_2)

      assert document.name === ""
    end

    test "attempting to assign another user's solution" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})

      user_1 = AccountHelpers.create_user(%{email: "user1@example.com"})
      solution_1 = SolutionHelpers.create_submitted_solution(%{}, user_1, challenge)

      user_2 = AccountHelpers.create_user(%{email: "user2@example.com"})
      document = SolutionDocumentHelpers.upload_document(user_2, "test/fixtures/test.pdf")

      {:error, _changeset} = SolutionDocuments.attach_to_solution(document, solution_1)
    end
  end

  describe "deleting a document" do
    test "successfully" do
      user = AccountHelpers.create_user()
      document = SolutionDocumentHelpers.upload_document(user, "test/fixtures/test.pdf")

      {:ok, _document} = SolutionDocuments.delete(document)
    end
  end
end
