defmodule IdeaPortal.SupportingDocumentsTest do
  use IdeaPortal.DataCase

  alias IdeaPortal.SupportingDocuments

  describe "uploading documents" do
    test "successfully" do
      user = TestHelpers.create_user()

      {:ok, document} =
        SupportingDocuments.upload(user, %{
          "file" => %{path: "test/fixtures/test.pdf"}
        })

      assert document.user_id == user.id
      assert document.extension == ".pdf"
      assert document.key
    end
  end

  describe "attaching to a challenge" do
    test "successfully" do
      user = TestHelpers.create_user()
      challenge = TestHelpers.create_challenge(user)
      document = TestHelpers.upload_document(user, "test/fixtures/test.pdf")

      {:ok, document} = SupportingDocuments.attach_to_challenge(document, challenge)

      assert document.challenge_id == challenge.id
    end

    test "already assigned" do
      user = TestHelpers.create_user()
      challenge_1 = TestHelpers.create_challenge(user)
      challenge_2 = TestHelpers.create_challenge(user)

      document = TestHelpers.upload_document(user, "test/fixtures/test.pdf")

      {:ok, document} = SupportingDocuments.attach_to_challenge(document, challenge_1)
      {:error, _changeset} = SupportingDocuments.attach_to_challenge(document, challenge_2)
    end

    test "attempting to assign another user's challenge" do
      user_1 = TestHelpers.create_user(%{email: "user1@example.com"})
      challenge = TestHelpers.create_challenge(user_1)

      user_2 = TestHelpers.create_user(%{email: "user2@example.com"})
      document = TestHelpers.upload_document(user_2, "test/fixtures/test.pdf")

      {:error, _changeset} = SupportingDocuments.attach_to_challenge(document, challenge)
    end
  end

  describe "deleting a document" do
    test "successfully" do
      user = TestHelpers.create_user()
      document = TestHelpers.upload_document(user, "test/fixtures/test.pdf")

      {:ok, _document} = SupportingDocuments.delete(document)
    end
  end
end
