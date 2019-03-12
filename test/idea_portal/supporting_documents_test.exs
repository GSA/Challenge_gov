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
end
